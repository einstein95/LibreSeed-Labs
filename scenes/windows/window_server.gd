extends WindowIndexed

@onready var upload := $PanelContainer/MainContainer/Upload
@onready var money := $PanelContainer/MainContainer/Money
@onready var value_label := $PanelContainer/MainContainer/StorageValue/Info/Count


func process(delta: float) -> void:
    var value: float = Globals.storage_value
    value_label.text = Utils.print_string(value, false) + "/b"
    money.production = upload.count * value

    money.add(floorf(money.production * delta))
