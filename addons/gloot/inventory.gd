extends Node
class_name Inventory
tool

signal item_added
signal item_removed
signal contents_changed
signal protoset_changed

export(Resource) var item_protoset: Resource setget _set_item_protoset
export(Array, String) var contents: Array setget _set_contents
var _items: Node

const KEY_ITEM_PROTOSET: String = "item_protoset"
const KEY_ITEMS: String = "items"


func _set_item_protoset(new_item_protoset: Resource) -> void:
    assert((new_item_protoset is ItemProtoset) || (new_item_protoset == null), \
        "item_protoset must be an ItemProtoset resource!")
    
    item_protoset = new_item_protoset
    emit_signal("protoset_changed")


func _set_contents(new_contents: Array) -> void:
    contents = new_contents


static func get_item_script() -> Script:
    return preload("inventory_item.gd")


func _ready() -> void:
    _items = Node.new()
    add_child(_items)
    _populate()


func _populate() -> void:
    for prototype_id in contents:
        var prototype: Dictionary = item_protoset.get(prototype_id)
        assert(!prototype.empty(), "Undefined item id '%s'" % prototype_id)
        var item = get_item_script().new()
        item.prototype_id = prototype_id
        item.protoset = item_protoset
        assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id)


func get_items() -> Array:
    if _items == null:
        return []

    return _items.get_children()


func has_item(item: InventoryItem) -> bool:
    return item.get_parent() == _items


func add_item(item: InventoryItem) -> bool:
    if item == null || has_item(item):
        return false

    if item.get_parent():
        item.get_parent().remove_child(item)

    _items.add_child(item)
    if !item.is_connected("tree_exited", self, "_on_item_tree_exited"):
        item.connect("tree_exited", self, "_on_item_tree_exited", [item])
    emit_signal("item_added", item)
    emit_signal("contents_changed")
    return true


func remove_item(item: InventoryItem) -> bool:
    if item == null || !has_item(item):
        return false

    if item.is_connected("tree_exited", self, "_on_item_tree_exited"):
        item.disconnect("tree_exited", self, "_on_item_tree_exited")
    _items.remove_child(item)
    emit_signal("item_removed", item)
    emit_signal("contents_changed")
    return true


func _on_item_tree_exited(item: InventoryItem) -> void:
    emit_signal("contents_changed")
    emit_signal("item_removed", item)


func get_item_by_id(id: String) -> InventoryItem:
    for item in get_items():
        if item.prototype_id == id:
            return item
            
    return null


func has_item_by_id(id: String) -> bool:
    return get_item_by_id(id) != null


func transfer(item: InventoryItem, destination: Inventory) -> bool:
    if remove_item(item):
        return destination.add_item(item)

    return false


func reset() -> void:
    clear()
    item_protoset = null


func clear() -> void:
    for item in get_items():
        remove_item(item)
        item.queue_free()
    contents.clear()


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_ITEM_PROTOSET] = item_protoset.resource_path
    if !get_items().empty():
        result[KEY_ITEMS] = []
        for item in get_items():
            result[KEY_ITEMS].append(item.serialize())

    return result


func deserialize(source: Dictionary) -> bool:
    if !GlootVerify.dict(source, true, KEY_ITEM_PROTOSET, TYPE_STRING) ||\
        !GlootVerify.dict(source, false, KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY):
        return false

    reset()

    item_protoset = load(source[KEY_ITEM_PROTOSET])
    if source.has(KEY_ITEMS):
        var items = source[KEY_ITEMS]
        for item_dict in items:
            var item = get_item_script().new()
            item.deserialize(item_dict)
            assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id)

    return true

