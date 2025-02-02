extends Node
class_name ItemSlot

signal item_set
signal item_cleared
signal inventory_changed


var inventory: Inventory setget _set_inventory
var item: InventoryItem setget _set_item

const KEY_INVENTORY: String = "inventory"
const KEY_ITEM: String = "item"


func _set_inventory(new_inv: Inventory) -> void:
    if inventory != null:
        inventory.disconnect("tree_exiting", self, "_on_inventory_tree_exiting")
        inventory.disconnect("item_removed", self, "_on_item_removed")

    if new_inv != inventory:
        _set_item(null)

    inventory = new_inv
    if inventory != null:
        inventory.connect("tree_exiting", self, "_on_inventory_tree_exiting")
        inventory.connect("item_removed", self, "_on_item_removed")

    emit_signal("inventory_changed", inventory)


func _set_item(new_item: InventoryItem) -> void:
    assert(can_hold_item(new_item))
    if inventory == null:
        return

    if new_item && !inventory.has_item(new_item):
        return

    if item != null:
        item.disconnect("tree_exiting", self, "_on_item_tree_exiting")

    item = new_item
    if item != null:
        item.connect("tree_exiting", self, "_on_item_tree_exiting")
        emit_signal("item_set", item)
    else:
        emit_signal("item_cleared")


func can_hold_item(new_item: InventoryItem) -> bool:
    if new_item == null:
        return true
    if inventory == null:
        return false
    if !inventory.has_item(new_item):
        return false

    return true


func _on_inventory_tree_exiting():
    inventory = null
    _set_item(null)


func _on_item_removed(pItem: InventoryItem) -> void:
    if pItem == item:
        _set_item(null)


func _on_item_tree_exiting():
    _set_item(null)


func reset():
    _set_inventory(null)
    _set_item(null)


func serialize() -> Dictionary:
    var result: Dictionary = {}

    if inventory:
        result[KEY_INVENTORY] = inventory.get_path()
    if item:
        result[KEY_ITEM] = item.get_path()

    return result


func deserialize(source: Dictionary) -> bool:
    if !GlootVerify.dict(source, false, KEY_INVENTORY, TYPE_NODE_PATH) ||\
        !GlootVerify.dict(source, false, KEY_ITEM, TYPE_NODE_PATH):
        return false

    reset()

    if source.has(KEY_INVENTORY):
        _set_inventory(get_node_or_null(source[KEY_INVENTORY]))
        if inventory == null:
            print("Warning: Node not found (%s)!" % source[KEY_INVENTORY])
            return false
    if source.has(KEY_ITEM):
        _set_item(get_node_or_null(source[KEY_ITEM]))
        if item == null:
            print("Warning: Node not found (%s)!" % source[KEY_ITEM])
            return false

    return true

