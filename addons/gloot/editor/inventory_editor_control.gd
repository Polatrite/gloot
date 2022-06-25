tool
extends Control

onready var item_list_prototypes = $VBoxContainer/HBoxContainer/PrototypesContainer/ItemList
onready var edt_filter_prototypes = $VBoxContainer/HBoxContainer/PrototypesContainer/LineEdit
onready var item_list_items = $VBoxContainer/HBoxContainer/ItemsContainer/ItemList
onready var edt_filter_items = $VBoxContainer/HBoxContainer/ItemsContainer/LineEdit
onready var btn_add = $VBoxContainer/HBoxContainer/PrototypesContainer/BtnAdd
onready var btn_remove = $VBoxContainer/HBoxContainer/ItemsContainer/BtnRemove

var inventory: Inventory


func _ready():
    btn_add.connect("pressed", self, "_on_btn_add")
    btn_remove.connect("pressed", self, "_on_btn_remove")
    item_list_prototypes.connect("item_activated", self, "_on_prototype_activated")
    item_list_items.connect("item_activated", self, "_on_item_activated")

    if inventory:
        edit(inventory)


func _on_prototype_activated(index: int) -> void:
    if inventory == null:
        return;
    inventory.contents.append(item_list_prototypes.get_item_text(index))
    _refresh()


func _on_item_activated(index: int) -> void:
    if inventory == null:
        return;
    inventory.contents.remove(index)
    _refresh()


func _on_btn_add() -> void:
    if inventory == null:
        return;

    for i in item_list_prototypes.get_selected_items():
        inventory.contents.append(item_list_prototypes.get_item_text(i))
        item_list_prototypes.unselect(i)
    _refresh()


func _on_btn_remove() -> void:
    if inventory == null:
        return;

    var selected_items: PoolIntArray = item_list_items.get_selected_items()
    for i in range(selected_items.size() - 1, -1, -1):
        inventory.contents.remove(selected_items[i])
    _refresh()


func edit(inv: Inventory) -> void:
    reset()
    inventory = inv
    if inventory == null:
        return

    for prototype_id in inventory.contents:
        item_list_items.add_item(prototype_id, _get_prototype_icon(prototype_id))
    for prototype_id in inventory.item_protoset._prototypes.keys():
        item_list_prototypes.add_item(prototype_id, _get_prototype_icon(prototype_id))


func _get_prototype_icon(prototype_id: String) -> Texture:
    var texture_path = inventory.item_protoset.get_item_property(prototype_id, "image")
    if texture_path:
        var resource = load(texture_path);
        if resource is Texture:
            return resource
    return null


func reset() -> void:
    item_list_items.clear()
    item_list_prototypes.clear()
    edt_filter_prototypes.text = ""
    edt_filter_items.text = ""
    inventory = null


func _refresh() -> void:
    var inv = inventory
    reset()
    edit(inv)