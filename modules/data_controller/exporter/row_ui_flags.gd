extends "./row_ui.gd"

## Container where flag checkboxes are added. Populated by setup().
@export var flags_container: HBoxContainer

var _flag_values: Array[int] = []
var _checkboxes: Array[CheckBox] = []


## Parse hint_string (e.g. "Page 1:1,Page 2:2,Page 3:4") into flag names and bit values.
static func _parse_hint_string(hint: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var bit_value: int = 1
	for part in hint.split(",", false):
		part = part.strip_edges()
		if part.is_empty():
			continue
		var name_value: PackedStringArray = part.split(":", false, 1)
		var flag_name: String = name_value[0].strip_edges()
		var value: int = bit_value
		if name_value.size() > 1:
			value = name_value[1].strip_edges().to_int()
			bit_value = value * 2
		else:
			bit_value *= 2
		result.append({"name": flag_name, "value": value})
	return result


func get_ui_val() -> int:
	var mask: int = 0
	for i in _checkboxes.size():
		if _checkboxes[i].button_pressed and i < _flag_values.size():
			mask |= _flag_values[i]
	return mask


func update_ui(val: int) -> void:
	for i in _checkboxes.size():
		if i < _flag_values.size():
			_checkboxes[i].button_pressed = (val & _flag_values[i]) != 0


func is_active() -> bool:
	for cb in _checkboxes:
		if cb.has_focus():
			return true
	return false


func setup(hint_string: String) -> void:
	var flags: Array[Dictionary] = _parse_hint_string(hint_string)
	for child in flags_container.get_children():
		child.queue_free()
	_checkboxes.clear()
	_flag_values.clear()
	for flag in flags:
		_flag_values.append(flag.value)
		var cb: CheckBox = CheckBox.new()
		cb.text = flag.name
		cb.toggled.connect(_on_checkbox_toggled)
		flags_container.add_child(cb)
		_checkboxes.append(cb)


func _on_checkbox_toggled(_toggled_on: bool) -> void:
	ui_val_changed.emit(get_ui_val())
