extends Node

signal dlc_installed(premium: String)

var api: Object
var initialized: bool
var auth_ticket: Dictionary
var client_auth_tickets: Array
var dlcs: Array


func _ready() -> void :
    if Engine.has_singleton("Steam"):
        api = Engine.get_singleton("Steam")
        initialized = true

        api.dlc_installed.connect(_on_dlc_installed)
        var initialize_response: Dictionary = api.steamInitEx()

        auth_ticket = api.getAuthSessionTicket()

        for i: String in Data.premiums:
            if int(Data.premiums[i].platform != 0): continue
            if api.isDLCInstalled(Data.premiums[i].id):
                dlcs.append(i)


func purchase_dlc(dlc: int) -> void :
    if !initialized: return

    api.activateGameOverlayToStore(dlc)


func _on_dlc_installed(app: int) -> void :
    if !initialized: return
    for i: String in Data.premiums:
        if dlcs.has(i): continue
        if int(Data.premiums[i].platform != 0): continue
        if api.isDLCInstalled(Data.premiums[i].id):
            dlcs.append(i)
            dlc_installed.emit(i)
