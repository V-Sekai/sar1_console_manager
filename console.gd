extends CanvasLayer

# Based off quentincaffeino's developer console
# Currently requires the addon to be included

const BaseCommands = preload('res://addons/quentincaffeino-console/src/Misc/BaseCommands.gd')
const DefaultActions = preload('res://addons/quentincaffeino-console/src/Action/DefaultActions.gd')
const DefaultActionServiceFactory = preload('res://addons/quentincaffeino-console/src/Action/DefaultActionServiceFactory.gd')
const CommandService = preload('res://addons/quentincaffeino-console/src/Command/CommandService.gd')

### Custom console types
const IntRangeType = preload('res://addons/quentincaffeino-console/src/Type/IntRangeType.gd')
const FloatRangeType = preload('res://addons/quentincaffeino-console/src/Type/FloatRangeType.gd')
const FilterType = preload('res://addons/quentincaffeino-console/src/Type/FilterType.gd')

## Signals

# @param  bool  is_console_shown
signal toggled(is_console_shown)
# @param  String       name
# @param  Reference    target
# @param  String|null  target_name
signal command_added(name, target, target_name)
# @param  String  name
signal command_removed(name)
# @param  Command  command
signal command_executed(command)
# @param  String  name
signal command_not_found(name)

# @var  History
var History = preload('res://addons/quentincaffeino-console/src/Misc/History.gd').new(Console, 100) :
	set = _set_protected


# @var  Logger
var Log = preload('res://addons/quentincaffeino-console/src/Misc/Logger.gd').new(Console) :
	set = _set_protected


# @var  Command/CommandService
var _command_service

# @var  ActionService
var _action_service

# Used to clear text from bb tags
# @var  RegEx
var _erase_bb_tags_regex

# @var  bool
var is_console_shown = true :
	set = set_is_console_shown


# @var  bool
var consume_input = true

# @var  Control
var previous_focus_owner = null


### Console nodes
@onready var _consoleBox = $ConsoleBox
@onready var Text = $ConsoleBox/Container/ConsoleText :
	set = _set_protected
@onready var Line = $ConsoleBox/Container/ConsoleLine :
	set = _set_protected
@onready var _animationPlayer = $ConsoleBox/AnimationPlayer


func _init():
	self._command_service = CommandService.new(self)
	self._action_service = DefaultActionServiceFactory.create()
	# Used to clear text from bb tags before printing to engine output
	self._erase_bb_tags_regex = RegEx.new()
	self._erase_bb_tags_regex.compile('\\[[\\/]?[a-z0-9\\=\\#\\ \\_\\-\\,\\.\\;]+\\]')


func _ready():
	print("Console _ready")
	print("Self is " + str(self) + " self._animationPlayer is " + str(self._animationPlayer))
	# Allow selecting console text
	self.Text.set_selection_enabled(true)
	# Follow console output (for scrolling)
	self.Text.set_scroll_follow(true)
	# React to clicks on console urls
	self.Text.meta_clicked.connect(self.Line.set_text)

	# Hide console by default
	self._consoleBox.hide()
	self._animationPlayer.animation_finished.connect(self._toggle_animation_finished)
	self.toggle_console()

	# Console keyboard control
	set_process_input(true)

	# Show some info
	var v = Engine.get_version_info()
	self.write_line(\
		ProjectSettings.get_setting("application/config/name") + \
		" (Godot " + str(v.major) + '.' + str(v.minor) + '.' + str(v.patch) + ' ' + v.status+")\n" + \
		"Type [color=#ffff66][url=help]help[/url][/color] to get more information about usage")

	# Init base commands
	self.BaseCommands.new(self)


# @param  InputEvent  e
func _input(e):
	if Input.is_action_just_pressed(self.get_action_service().get_real_action_name(DefaultActions.action_console_toggle)):
		self.toggle_console()


# @returns  Command/CommandService
func get_command_service():
	return self._command_service


# @returns  Action/ActionService
func get_action_service():
	return self._action_service

# @param    String  name
# @returns  Command/Command|null
func get_command(name):
	return self._command_service.get(name)

# @param    String  name
# @returns  Command/CommandCollection
func find_commands(name):
	return self._command_service.find(name)

# Example usage:
# ```gdscript
# Console.add_command('sayHello', self, 'print_hello')\
# 	.set_description('Prints "Hello %name%!"')\
# 	.add_argument('name', TYPE_STRING)\
# 	.register()
# ```
# @param    String       name
# @param    Reference    target
# @param    String|null  target_name
# @returns  Command/CommandBuilder
func add_command(name, target, target_name = null):
	command_added.emit(name, target, target_name)
	return self._command_service.create(name, target, target_name)

# @param    String  name
# @returns  int
func remove_command(name):
	command_removed.emit(name)
	return self._command_service.remove_at(name)


# @param    String  message
# @returns  void
func write(message):
	message = str(message)
	if self.Text:
		self.Text.append_text(message)
	print(self._erase_bb_tags_regex.sub(message, '', true))


# @param    String  message
# @returns  void
func write_line(message = ''):
	message = str(message)
	if self.Text:
		self.Text.append_text(message + '\n')
	print(self._erase_bb_tags_regex.sub(message, '', true))


# @returns  void
func clear():
	if self.Text:
		self.Text.text = ''


func set_is_console_shown(value):
	# Open the console
	if value and !is_console_shown:
		previous_focus_owner = self.Line.get_focus_owner()
		self._consoleBox.show()
		self.Line.clear()
		self.Line.grab_focus()
		self._animationPlayer.play_backwards('fade')
		$InputBlocker.mouse_filter = Control.MOUSE_FILTER_STOP
	elif !value and is_console_shown:
		self.Line.accept_event() # Prevents from DefaultActions.action_console_toggle key character getting into previous_focus_owner value
		if is_instance_valid(previous_focus_owner):
			previous_focus_owner.grab_focus()
		previous_focus_owner = null
		self._animationPlayer.play('fade')
		$InputBlocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

	is_console_shown = value
	toggled.emit(is_console_shown)

	return self

# @returns  Console
func toggle_console():
	self.is_console_shown = !self.is_console_shown
	return self


# @returns  void
func _toggle_animation_finished(animation):
	if !self.is_console_shown:
		self._consoleBox.hide()


# @returns  void
func _set_protected(value):
	Log.warn('QC/Console: set_protected: Attempted to set a protected variable, ignoring.')
