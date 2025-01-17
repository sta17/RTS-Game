@icon("res://Assets/Mine/yellow_node.svg")
extends Control

@onready var UnitIcon:TextureButton = $TextureButton

@export var isDisable:bool = false

var index: int

var listener

func changeIcon(newIcon:Texture2D) -> void:
	if newIcon:
		UnitIcon.texture_normal = newIcon
		UnitIcon.texture_pressed = newIcon
		UnitIcon.texture_hover = newIcon
		UnitIcon.texture_focused = newIcon
		enableButton()
	else:
		disableButton()

func disableButton():
	UnitIcon.visible = false
	UnitIcon.disabled = true
	isDisable = true

func enableButton():
	UnitIcon.visible = true
	UnitIcon.disabled = false
	isDisable = false

func _on_texture_button_pressed():
	if listener and !isDisable:
		listener.hero_display_button(index)
		print("listener is done")
