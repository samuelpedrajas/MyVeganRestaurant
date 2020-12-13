extends Node


func sort_by_attribute(array, attribute):
	var items = []
	for item in array:
		items.append({
			"object": item,
			"attribute": attribute
		})
	items.sort_custom(self, "customComparison")
	var result = []
	for item in items:
		result.append(item["object"])
	return result


func _attribute_comparison(a, b):
	var object_a = a["object"]
	var object_b = b["object"]
	var attribute = a["attribute"]
	var value_a = object_a.get_attribute_value(attribute)
	var value_b = object_b.get_attribute_value(attribute)
	return value_a < value_b
