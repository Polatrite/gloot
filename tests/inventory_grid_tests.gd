extends Test


func run_tests():
    var inventory_3x3 = $InventoryGrid3x3
    var item_1x1 = $Item_1x1
    var item_2x2 = $Item_2x2

    assert(!inventory_3x3.add_item_at(item_1x1, Vector2(4, 4)))
    assert(!inventory_3x3.add_item_at(item_1x1, Vector2(3, 3)))
    assert(inventory_3x3.add_item_at(item_1x1, Vector2(0, 0)))

    assert(!inventory_3x3.add_item_at(item_2x2, Vector2(0, 0)))
    assert(!inventory_3x3.add_item_at(item_2x2, Vector2(2, 2)))
    var free_place: Vector2 = inventory_3x3.find_free_place(item_2x2)
    assert(free_place.x == 0)
    assert(free_place.y == 1)
    assert(inventory_3x3.add_item_at(item_2x2, Vector2(1, 0)))

    inventory_3x3.size.y = 2
    assert(inventory_3x3.size.y == 2)
    inventory_3x3.size.y = 3
    assert(inventory_3x3.size.y == 3)
    inventory_3x3.size.x = 2
    assert(inventory_3x3.size.x == 3)

    var inventory_data = inventory_3x3.serialize()
    inventory_3x3.reset()
    assert(inventory_3x3.get_items().empty())
    assert(inventory_3x3.size == InventoryGrid.DEFAULT_SIZE)
    assert(inventory_3x3.deserialize(inventory_data))
    assert(inventory_3x3.get_items().size() == 2)
    assert(inventory_3x3.size.x == 3)
    assert(inventory_3x3.size.y == 3)
