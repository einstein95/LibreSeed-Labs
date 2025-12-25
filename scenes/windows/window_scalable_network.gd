extends WindowIndexed

const base: float = pow(10, 18)

@onready var routers := $PanelContainer/MainContainer/Routers
@onready var boost := $PanelContainer/MainContainer/Boost
@onready var download := $PanelContainer/MainContainer/Download
@onready var upload := $PanelContainer/MainContainer/Upload


func process(delta: float) -> void:
    download.count = base * pow(routers.count, 0.4) * (1.0 + boost.count) * Attributes.get_attribute("bandwidth_multiplier") * Attributes.get_attribute("download_speed_multiplier")
    upload.count = base * pow(routers.count, 0.4) * (1.0 + boost.count) * Attributes.get_attribute("bandwidth_multiplier") * Attributes.get_attribute("upload_speed_multiplier")
