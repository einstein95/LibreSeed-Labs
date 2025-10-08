extends Node

signal updated

var is_ready: bool
var level: int
var premiums: Dictionary
var billing: Object
var product_details: Dictionary
var billing_owned: Array
var features: Array[String]


func _enter_tree() -> void :
    for i: String in Data.premiums:
        premiums[i] = false


func _ready() -> void :
    if Engine.has_singleton("AndroidIAPP"):
        billing = Engine.get_singleton("AndroidIAPP")
        billing.connected.connect(_on_connected)
        billing.query_purchases.connect(_on_query_purchases)
        billing.query_product_details.connect(_on_query_product_details)
        billing.purchase_updated.connect(_on_purchase_updated)
        billing.startConnection()
    elif ClassDB.class_exists("InAppPurchase"):
        billing = ClassDB.instantiate("InAppPurchase")
        billing.in_app_purchase_fetch_success.connect(_on_in_app_purchase_fetch_success)
        billing.in_app_purchase_success.connect(_on_in_app_purchase_success)
        billing.in_app_purchase_restore_success.connect(_on_in_app_purchase_restore_success)

        get_tree().create_timer(1).timeout.connect( func() -> void :
            var fetching: Array[String]
            for i: String in Data.premiums:
                if int(Data.premiums[i].platform) == 3:
                    fetching.append(Data.premiums[i].id)
            billing.fetchProducts(fetching)
        )

    if Globals.platform == 0 or Globals.platform == 1:
        GlobalSteam.dlc_installed.connect(_on_dlc_installed)
        is_ready = true


func update_premiums() -> void :
    features.clear()
    level = 0
    for i: String in Data.premiums:
        if Globals.platform == 0 or Globals.platform == 1:
            premiums[i] = GlobalSteam.dlcs.has(i)
        if Globals.platform == 2:
            premiums[i] = billing_owned.has(i)
        if Globals.platform == 3:
            premiums[i] = Globals.premiums.has(i)

    for premium: String in premiums:
        if !premiums[premium]: continue
        for i: String in Data.premiums[premium].features:
            features.append(i)
        level += 1

    updated.emit()


func reload() -> void :
    if Globals.platform == 0 or Globals.platform == 1:
        update_premiums()
    elif Globals.platform == 2 and billing.isReady():
        var querying: Array[String]
        for i: String in Data.premiums:
            if int(Data.premiums[i].platform) == 2:
                querying.append(Data.premiums[i].id)
        billing.queryProductDetails(querying, "inapp")
    elif Globals.platform == 3:
        billing.restorePurchases()


func attempt_purchase(premium: String) -> void :
    if premiums[premium]: return
    if int(Data.premiums[premium].platform) != Globals.platform: return

    if Globals.platform == 0:
        GlobalSteam.purchase_dlc(Data.premiums[premium].id)
    elif Globals.platform == 2:
        if billing and billing.isReady():
            billing.purchase([Data.premiums[premium].id], false)
    elif Globals.platform == 3:
        billing.purchaseProduct(Data.premiums[premium].id)


func _on_connected() -> void :
    reload()


func _on_dlc_installed(premium: String) -> void :
    update_premiums()


func _on_query_product_details(response) -> void :
    for product in response["product_details_list"]:
        for i: String in Data.premiums:
            if int(Data.premiums[i].platform) != 2: continue
            if Data.premiums[i].id == product["product_id"]:
                product_details[product["product_id"]] = {"premium": i, 
                "price": product["one_time_purchase_offer_details"]["formatted_price"]}
    billing.queryPurchases("inapp")


func _on_query_purchases(response) -> void :
    for purchase in response["purchases_list"]:
        process_purchase(purchase)


func _on_purchase_updated(response):
    for purchase in response["purchases_list"]:
        process_purchase(purchase)
        is_ready = true


func _on_in_app_purchase_fetch_success(products: Array) -> void :
    for product in products:
        for i: String in Data.premiums:
            if int(Data.premiums[i].platform) != 3: continue
            if Data.premiums[i].id == product.identifier:
                product_details[product.identifier] = {"premium": i, 
                "price": product.displayPrice}


func _on_in_app_purchase_success(identifier: String) -> void :
    var id: String = product_details[identifier].premium
    if !Globals.premiums.has(id):
        Globals.premiums.append(id)
    update_premiums()


func _on_in_app_purchase_restore_success(product_ids: Array) -> void :
    Globals.premiums.clear()
    for i: String in product_ids:
        var id: String = product_details[i].premium
        Globals.premiums.append(id)
    update_premiums()


func process_purchase(purchase):
    for product in purchase["products"]:
        if not purchase["is_acknowledged"]:
            billing.acknowledgePurchase(purchase["purchase_token"])
        var id: String = product_details[product].premium
        if !billing_owned.has(id):
            billing_owned.append(id)
    update_premiums()
