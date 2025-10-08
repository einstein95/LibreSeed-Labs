extends WindowIndexed

@onready var download: = $PanelContainer / MainContainer / Download
@onready var upload: = $PanelContainer / MainContainer / Upload
@onready var download_out: = $PanelContainer / MainContainer / DownloadOut
@onready var upload_out: = $PanelContainer / MainContainer / UploadOut


func process(delta: float) -> void :
    download_out.count = upload.count
    upload_out.count = download.count
