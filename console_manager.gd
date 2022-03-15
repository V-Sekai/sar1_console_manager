extends Node

signal console_active(p_active)

var console: CanvasLayer = null

var console_is_active: bool = false

func is_console_active() -> bool:
	return console_is_active

func get_console() -> Node:
	return console
	
func add_command(p_name: String, p_target: Node, p_target_name = null):
	return console.add_command(p_name, p_target, p_target_name)
	
func printl(p_string: String) -> void:
	print(p_string)
	
func error(p_string: String) -> void:
	push_error("ERROR: " + p_string)
	
func fatal_error(p_string: String) -> void:
	push_error("FATAL_ERROR: " + p_string)
	
func _console_toggled(p_console_toggled: bool) -> void:
	if p_console_toggled:
		console_is_active = true
		console_active.emit(true)

func _toggle_animation_finished(p_anim_name) -> void:
	if !console.is_console_shown and p_anim_name == "fade":
		console_active.emit(false)
	
func toggle_console() -> void:
	console.toggle_console()
		
func _ready():
	print("ConsoleManager _ready")
	console = $"/root/Console"
	assert(console.toggled.connect(self._console_toggled) == OK)
	print("Console is " + str(console) + " console._animationPlayer is " + str(console._animationPlayer))
	assert(console._animationPlayer.animation_finished.connect(self._toggle_animation_finished) == OK)
