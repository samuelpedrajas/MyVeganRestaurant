extends Node


func arrays_have_same_content(array1, array2):
	if array1.size() != array2.size(): return false
	for item in array1:
		if !array2.has(item): return false
		if array1.count(item) != array2.count(item): return false
	return true


func sort_by_attribute(array, attribute, _order):
	var items = []
	for item in array:
		items.append({
			"object": item,
			"attribute": attribute,
			"order": _order
		})
	items.sort_custom(self, "_attribute_comparison")
	var result = []
	for item in items:
		result.append(item["object"])
	return result


func _attribute_comparison(a, b):
	var object_a = a["object"]
	var object_b = b["object"]
	var attribute = a["attribute"]
	var order = a["order"]
	var value_a
	var value_b
	if typeof(object_a) == TYPE_DICTIONARY:
		value_a = object_a[attribute]
		value_b = object_b[attribute]
	else:
		value_a = object_a.get_attribute_value(attribute)
		value_b = object_b.get_attribute_value(attribute)

	if order == "desc":
		return value_a > value_b
	return value_a < value_b


func initialise_array(s, v):
	var l = []
	for _i in range(0, s):
		var val = v
		if typeof(v) in [TYPE_ARRAY, TYPE_DICTIONARY]:
			val = v.duplicate()
		l.append(val)
	return l
