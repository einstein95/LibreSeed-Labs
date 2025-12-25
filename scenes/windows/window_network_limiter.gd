extends WindowIndexed

@onready var download_splitting := $PanelContainer/MainContainer/Download/Splitting
@onready var download_splitted := $PanelContainer/MainContainer/Download/Splitted
@onready var download_splitted2 := $PanelContainer/MainContainer/Download/Splitted2
@onready var upload_splitting := $PanelContainer/MainContainer/Upload/Splitting
@onready var upload_splitted := $PanelContainer/MainContainer/Upload/Splitted
@onready var upload_splitted2 := $PanelContainer/MainContainer/Upload/Splitted2

var download_ratio: float = 0.5
var upload_ratio: float = 0.5


func _ready() -> void:
    super ()
    update_all()


func process(delta: float) -> void:
    download_splitted.count = download_splitting.count * (1 - download_ratio)
    download_splitted2.count = download_splitting.count * download_ratio
    upload_splitted.count = upload_splitting.count * (1 - upload_ratio)
    upload_splitted2.count = upload_splitting.count * upload_ratio


func update_all() -> void:
    $PanelContainer/MainContainer/Download/RatioContainer/RatioSlider.value = download_ratio
    $PanelContainer/MainContainer/Download/RatioContainer/RatioLabelContainer/RatioLabel.text = "%.0f" % ((1 - download_ratio) * 10) + " : " + "%.0f" % (download_ratio * 10)
    $PanelContainer/MainContainer/Upload/RatioContainer/RatioSlider.value = upload_ratio
    $PanelContainer/MainContainer/Upload/RatioContainer/RatioLabelContainer/RatioLabel.text = "%.0f" % ((1 - upload_ratio) * 10) + " : " + "%.0f" % (upload_ratio * 10)


func _on_download_ratio_slider_drag_ended(value_changed: bool) -> void:
    download_ratio = $PanelContainer/MainContainer/Download/RatioContainer/RatioSlider.value
    Sound.play("click")
    update_all()


func _on_upload_ratio_slider_drag_ended(value_changed: bool) -> void:
    upload_ratio = $PanelContainer/MainContainer/Upload/RatioContainer/RatioSlider.value
    Sound.play("click")
    update_all()


func save() -> Dictionary:
    return super ().merged({
        "download_ratio": download_ratio,
        "upload_ratio": upload_ratio
    })
