extends Node

signal console_active(p_active)

var console: CanvasLayer = null

var console_is_active: bool = false

func is_console_active() -> bool:
	return console_is_active

func get_console() -> Node:
	return console
	
func add_command(p_name: String, p_target: Node, p_target_name = null):
	pass
	
func printl(p_string: String) -> void:
	print(p_string)
	
func error(p_string: String) -> void:
	push_error("ERROR: " + p_string)
	
func fatal_error(p_string: String) -> void:
	push_error("FATAL_ERROR: " + p_string)
	
