extends Node

signal console_active(p_active)

var console: CanvasLayer = null

var console_is_active: bool = false

func is_console_active() -> bool:
	return console_is_active

func get_console() -> Node:
	return console
	
func add_command(p_name: String, p_target: Node, p_target_name = null):
	if console:
		return console.add_command(p_name, p_target, p_target_name)
	else:
		return null
	
func printl(p_string: String) -> void:
	get_console().write_line(p_string)
	
func error(p_string: String) -> void:
	get_console().write_line("ERROR: " + p_string)
	
func fatal_error(p_string: String) -> void:
	get_console().write_line("FATAL_ERROR: " + p_string)
	
func _console_toggled(p_console_toggled: bool) -> void:
	if p_console_toggled:
		console_is_active = true
		emit_signal("console_active", true)

func _toggle_animation_finished(p_anim_name) -> void:
	if !console.is_console_shown and p_anim_name == "fade":
		emit_signal("console_active", false)
	
func toggle_console() -> void:
	console.toggle_console()
		
func _ready():
	var n:Variant = Console
	console = n
	assert(console.connect("toggled", Callable(self, "_console_toggled")) == OK)
	assert(console._animationPlayer.connect("animation_finished", Callable(self, "_toggle_animation_finished")) == OK)
