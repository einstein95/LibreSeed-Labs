extends PanelContainer


func _ready() -> void:
    pass


func _process(delta: float) -> void:
    if Globals.is_mobile():
        offset_bottom = 119 - DisplayServer.virtual_keyboard_get_height()


func export() -> void:
    var save: String = Data.get_save_as_file().encode_to_text()
    $HTTPRequest.request("https://api.enigmastudio.dev/v1/3/store_save", ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"save": save}))
    $SyncContainer/Buttons/Sync.disabled = true
    $SyncContainer/MainPanel/InfoContainer/Code.editable = false
    $SyncContainer/MainPanel/InfoContainer/Response.text = tr("sending") + "..."


func import(code: String) -> void:
    if is_code_valid(code):
        $HTTPRequest.request("https://api.enigmastudio.dev/v1/3/get_save/" + code, ["Content-Type: application/json"], HTTPClient.METHOD_GET)
        $SyncContainer/Buttons/Sync.disabled = true
        $SyncContainer/MainPanel/InfoContainer/Code.editable = false
        $SyncContainer/MainPanel/InfoContainer/Response.text = tr("connecting") + "..."
    else:
        $SyncContainer/MainPanel/InfoContainer/Response.text = "code_invalid"


func _on_cancel_pressed() -> void:
    Signals.popup.emit("")
    Sound.play("close")


func _on_sync_pressed() -> void:
    if $SyncContainer/MainPanel/InfoContainer/Code.text.is_empty():
        export()
    else:
        import($SyncContainer/MainPanel/InfoContainer/Code.text)

    Sound.play("click2")


func is_code_valid(code: String) -> bool:
    if code.length() != 6:
        return false

    return true


func _on_code_text_changed(new_text: String) -> void:
    if new_text.is_empty():
        $SyncContainer/Buttons/Sync.text = "action_export"
    else:
        $SyncContainer/Buttons/Sync.text = "action_import"


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    if visible:
        if response_code == 201:
            var json: JSON = JSON.new()
            var data = json.parse(body.get_string_from_utf8())
            if data == OK and json.data.success:
                $SyncContainer/MainPanel/InfoContainer/Code.text = json.data.code
            $SyncContainer/MainPanel/InfoContainer/Response.text = "exported"

            $SyncContainer/Buttons/Sync.text = "action_import"
        elif response_code == 200:
            var json: JSON = JSON.new()
            var data = json.parse(body.get_string_from_utf8())
            if data == OK and json.data.success:
                var file: ConfigFile = Data.load_save_string(json.data.data.save)
                Data.loading = Data.get_data_from_config(file)
                get_tree().change_scene_to_file("res://boot.tscn")
        elif response_code == 400:
            $SyncContainer/MainPanel/InfoContainer/Response.text = "code_invalid"
        elif response_code == 404:
            $SyncContainer/MainPanel/InfoContainer/Response.text = "code_expired"
        elif response_code == 429:
            var json: JSON = JSON.new()
            var data = json.parse(body.get_string_from_utf8())
            if data == OK:
                $SyncContainer/MainPanel/InfoContainer/Response.text = tr("rate_limited").replace("#", json.data.detail.retry_after)
        else:
            $SyncContainer/MainPanel/InfoContainer/Response.text = tr("error") + ": " + str(response_code)

    $SyncContainer/Buttons/Sync.disabled = false
    $SyncContainer/MainPanel/InfoContainer/Code.editable = true
