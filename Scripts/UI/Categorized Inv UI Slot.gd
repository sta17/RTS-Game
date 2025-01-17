@icon("res://Assets/Inventory Addin/node_inventory_system_base.svg")
extends Panel
class_name Categorized_Inv_UI_Slot

@export var ItemSilhouette:Texture
@export var categories : Array[ItemCategory]

@onready var tooltiphandler
@export var index: int
var inv: Inv
var multi_handler: Object
var input_handler: Object

@onready var Silhouette:TextureRect = $Silhouette
@onready var inv_UI_Slot:Inv_UI_Slot = $"inv_ui_slot 64"

func _ready():
	if ItemSilhouette:
		Silhouette.texture = ItemSilhouette
		Silhouette.visible = true
	inv_UI_Slot._ready()
	inv_UI_Slot.setUse_visual_unfilled(false)

func update(slot: InvSlot):
	if slot:
		if !slot.Item:
			hide_slot_visual()
		else:
			Silhouette.visible = false
		inv_UI_Slot.update(slot)

func initialize():
	inv_UI_Slot.index = index
	inv_UI_Slot.inv = inv
	inv_UI_Slot.multi_handler = multi_handler
	inv_UI_Slot.tooltiphandler = tooltiphandler
	inv_UI_Slot.input_handler = input_handler

func set_inv(newinv:Inv):
	inv = newinv
	inv_UI_Slot.inv = inv

func RemoveSlotData():
	hide_slot_visual()
	inv_UI_Slot.RemoveSlotData()

func hide_main_slot_visual():
	inv_UI_Slot.hide_main_slot_visual()

func show_main_slot_visual():
	inv_UI_Slot.show_main_slot_visual()

func OpenCloseSlotSwitch(newState: bool):
	inv_UI_Slot.OpenCloseSlotSwitch(newState)

func hide_slot_visual():
	inv_UI_Slot.hide_slot_visual()
	Silhouette.visible = true
	
func show_slot_visual():
	inv_UI_Slot.show_slot_visual()
	Silhouette.visible = false

func _can_drop_data(at_position, data):
	if inv_UI_Slot.is_legal_drop(data):
		if inv_UI_Slot.is_legal_at_index(data):
			for i in categories:
				for o in data["SlotData"].Item.categories:
					if i == o:
						return true
	return false
	
	return inv_UI_Slot._can_drop_data(at_position, data)

#func _notification(notification_type):
#	inv_UI_Slot._notification(notification_type)
	
func _drop_data(at_position, data):
	inv_UI_Slot._drop_data(at_position, data)
