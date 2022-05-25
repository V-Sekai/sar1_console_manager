@tool
extends EditorPlugin

var editor_interface: EditorInterface = null


func _init():
	print("Initialising ConsoleManager plugin")


func _notification(p_notification: int):
	match p_notification:
		NOTIFICATION_PREDELETE:
			print("Destroying ConsoleManager plugin")


func _get_plugin_name() -> String:
	return "ConsoleManager"


func _enter_tree() -> void:
	editor_interface = get_editor_interface()
	add_autoload_singleton("ConsoleManager", "res://addons/sar1_console_manager/console_manager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ConsoleManager")
