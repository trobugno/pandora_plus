@tool
extends AcceptDialog
class_name PPUpdateDialog
## Popup dialog shown when a Pandora+ update is available.
##
## Displays version info, changelog, and provides buttons for:
## - Update Now (auto-download from GitHub Releases)
## - Skip This Version
## - Remind Me Later


signal skip_requested(version: String)
signal remind_later_requested

var _local_version: String = ""
var _remote_version: String = ""
var _edition_data: Dictionary = {}

# UI Nodes
var _version_label: Label
var _changelog_text: TextEdit
var _update_button: Button
var _skip_button: Button
var _remind_button: Button
var _progress_section: VBoxContainer
var _progress_bar: ProgressBar
var _progress_label: Label
var _post_update_label: Label

# Components
var _addon_updater: PPAddonUpdater


func _ready() -> void:
	_build_ui()


## Sets up the dialog with version info and changelog.
func setup(local_ver: String, remote_ver: String, edition_data: Dictionary) -> void:
	_local_version = local_ver
	_remote_version = remote_ver
	_edition_data = edition_data

	if _version_label:
		_update_display()


func _build_ui() -> void:
	title = "Pandora+ Update Available"
	min_size = Vector2i(550, 420)
	max_size = Vector2i(550, 420)
	unresizable = true
	ok_button_text = ""
	get_ok_button().hide()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var main_vbox := VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(main_vbox)

	# Version info
	_version_label = Label.new()
	_version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(_version_label)

	# Separator
	main_vbox.add_child(HSeparator.new())

	# Changelog header
	var changelog_header := Label.new()
	changelog_header.text = "What's New:"
	changelog_header.add_theme_font_size_override("font_size", 14)
	main_vbox.add_child(changelog_header)

	# Changelog text
	_changelog_text = TextEdit.new()
	_changelog_text.editable = false
	_changelog_text.custom_minimum_size = Vector2(0, 180)
	_changelog_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_changelog_text.context_menu_enabled = false
	_changelog_text.shortcut_keys_enabled = false
	_changelog_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	main_vbox.add_child(_changelog_text)

	# Progress section (hidden by default)
	_progress_section = VBoxContainer.new()
	_progress_section.visible = false
	main_vbox.add_child(_progress_section)

	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(0, 20)
	_progress_section.add_child(_progress_bar)

	_progress_label = Label.new()
	_progress_label.text = "Downloading..."
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_section.add_child(_progress_label)

	# Post-update label (hidden by default)
	_post_update_label = Label.new()
	_post_update_label.visible = false
	_post_update_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_post_update_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(_post_update_label)

	# Separator before buttons
	main_vbox.add_child(HSeparator.new())

	# Action buttons
	var button_container := HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 12)
	main_vbox.add_child(button_container)

	_update_button = Button.new()
	_update_button.text = "Update Now"
	_update_button.pressed.connect(_on_update_pressed)
	button_container.add_child(_update_button)

	_skip_button = Button.new()
	_skip_button.text = "Skip This Version"
	_skip_button.pressed.connect(_on_skip_pressed)
	button_container.add_child(_skip_button)

	_remind_button = Button.new()
	_remind_button.text = "Remind Me Later"
	_remind_button.pressed.connect(_on_remind_pressed)
	button_container.add_child(_remind_button)

	# Apply setup data if already available
	if not _remote_version.is_empty():
		_update_display()


func _update_display() -> void:
	_version_label.text = "Current: %s  →  New: %s" % [_local_version, _remote_version]

	var changelog: String = _edition_data.get("changelog", "No changelog available.")
	_changelog_text.text = changelog


func _on_update_pressed() -> void:
	_start_core_update()


func _start_core_update() -> void:
	var download_url: String = _edition_data.get("download_url", "")
	if download_url.is_empty():
		_show_message("Error: No download URL available.")
		return

	_set_buttons_enabled(false)
	_progress_section.visible = true
	_progress_bar.value = 50 # Indeterminate-style

	_addon_updater = PPAddonUpdater.new()
	_addon_updater.progress_updated.connect(_on_progress)
	_addon_updater.update_completed.connect(_on_update_completed)
	_addon_updater.download_update(download_url, self)


func _on_progress(status: String) -> void:
	_progress_label.text = status


func _on_update_completed(success: bool, message: String) -> void:
	_progress_section.visible = false

	if success:
		_show_message(message)
		# Replace buttons with restart button
		_update_button.text = "Restart Editor"
		_update_button.visible = true
		_update_button.disabled = false
		_update_button.pressed.disconnect(_on_update_pressed)
		_update_button.pressed.connect(_request_restart)
		_skip_button.visible = false
		_remind_button.visible = false
	else:
		_show_message("Update failed: " + message)
		_set_buttons_enabled(true)


func _request_restart() -> void:
	if _addon_updater:
		var editor_plugin: EditorPlugin = Engine.get_meta("PandoraEditorPlugin", null)
		if editor_plugin == null:
			# Try parent chain
			var parent := get_parent()
			while parent:
				if parent is EditorPlugin:
					editor_plugin = parent
					break
				parent = parent.get_parent()

		if editor_plugin:
			_addon_updater.request_editor_restart(editor_plugin)


func _on_skip_pressed() -> void:
	skip_requested.emit(_remote_version)


func _on_remind_pressed() -> void:
	remind_later_requested.emit()


func _set_buttons_enabled(enabled: bool) -> void:
	_update_button.disabled = not enabled
	_skip_button.disabled = not enabled
	_remind_button.disabled = not enabled


func _show_message(text: String) -> void:
	_post_update_label.text = text
	_post_update_label.visible = true
