extends Node2D

var _delivery_category = {}
var _delivery_name_to_delivery = {}
var _prices = {}
var _discard_prices = {}
var _delivery_upgrade = {}


func _ready():
	for category in get_children():
		for _delivery in category.get_children():
			var delivery_name = _delivery.get_name()
			var category_name = category.get_name()
			_delivery_category[delivery_name] = category_name
			_delivery_name_to_delivery[delivery_name] = _delivery


func get_base_prices():
	var base_prices = {}
	for delivery_name in _prices.keys():
		base_prices[delivery_name] = _prices[delivery_name][0]
	return base_prices


func get_price(delivery_ref):
	return _prices[delivery_ref][_delivery_upgrade[delivery_ref]]


func get_base_price(delivery_ref):
	return _prices[delivery_ref][0]


func get_discard_price(delivery_ref):
	return _discard_prices[delivery_ref][_delivery_upgrade[delivery_ref]]


func get_order(category_name):
	return get_node(category_name).get_position_in_parent()


func configure_deliverables(kitchen_config, kitchen_status):
	var deliverables = kitchen_config["Deliverables"]
	var status = kitchen_status["Deliverables"]
	for deliverable_name  in deliverables.keys():
		var deliverable_level = status[deliverable_name]
		var deliverable_info = deliverables[deliverable_name]

		# config main
		var delivery = _delivery_name_to_delivery[deliverable_name]
		delivery.set_config(deliverable_level)
		_delivery_upgrade[deliverable_name] = deliverable_level
		_prices[deliverable_name] = deliverable_info["Prices"]
		_discard_prices[deliverable_name] = deliverable_info["DiscardPrices"]
	
		# config related
		var related_deliverables = deliverable_info["RelatedDeliverables"]
		for _deliverable_name in related_deliverables.keys():
			var related_info = related_deliverables[_deliverable_name]
			delivery = _delivery_name_to_delivery[_deliverable_name]
			delivery.set_config(deliverable_level)
			_delivery_upgrade[_deliverable_name] = deliverable_level
			_prices[_deliverable_name] = related_info["Prices"]
			_discard_prices[_deliverable_name] = related_info["DiscardPrices"]

		# config ingredient sources
		var related_sources = deliverable_info["RelatedSources"]
		for _source_name in related_sources.keys():
			var sources = get_tree().get_nodes_in_group(_source_name)
			var source_config = related_sources[_source_name]
			for source in sources:
				source.set_config(deliverable_level)
				source.ingredient.set_config(deliverable_level)

				var ingredient_name = source.ingredient.reference
				_delivery_upgrade[ingredient_name] = deliverable_level
				_discard_prices[ingredient_name] = source_config["DiscardPrices"]


func get_new_delivery(delivery, ingredient):
	var new_delivery = _get_new_delivery(delivery, ingredient)
	if new_delivery == null:
		return null
	return new_delivery.duplicate()


func get_delivery(reference):
	return _delivery_name_to_delivery[reference]


func get_delivery_category(reference):
	return _delivery_category[reference]


func _get_new_delivery(delivery, ingredient):
	var ingredients = []
	if delivery != null:
		ingredients += delivery.ingredients
	ingredients.append(ingredient.get_level_reference())

	for _delivery in _delivery_name_to_delivery.values():
		if Utils.arrays_have_same_content(ingredients, _delivery.ingredients):
			return _delivery
	return null
