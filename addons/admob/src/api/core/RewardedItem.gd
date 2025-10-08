





















class_name RewardedItem

var amount: int
var type: String

func _init(amount: int, type: String):
    self.amount = amount
    self.type = type

static func create(rewarded_item_dictionary: Dictionary) -> RewardedItem:
    if not rewarded_item_dictionary.is_empty():
        var amount: int = rewarded_item_dictionary["amount"]
        var type: String = rewarded_item_dictionary["type"]

        return RewardedItem.new(amount, type)
    return null
