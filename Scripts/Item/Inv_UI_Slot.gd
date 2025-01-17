@icon("res://Assets/Inventory Addin/node_inventory_system_base.svg")
extends Panel
class_name Inv_UI_Slot

@onready var item_visual: TextureRect = $Panel/TextureRect
@onready var amount_text:Label = $Panel/Label
@onready var frame:TextureRect = $TextureRect
@onready var mainslot:Panel = $Panel

@onready var visual_closed: TextureRect = $"TextureRect Closed"
@onready var visual_open: TextureRect = $"TextureRect Open"
@onready var visual_unfilled: TextureRect = $"TextureRect Unfilled"

@onready var tooltiphandler

@export var index: int

var inv: Inv

var multi_handler: Object

var input_handler: Object

var isClosed: bool = true
var dragging: bool = false
var filled: bool = false
var use_visual_unfilled: bool = true
var amount: int

@export var slotData: InvSlot

func _ready():
	hide_slot_visual()
	OpenCloseSlotGraphics()

func update(slot: InvSlot):
	if !slot.Item:
		hide_slot_visual()
		filled = false
	else:
		slotData = slot
		item_visual.texture = slot.Item.icon
		amount_text.visible = false
		if slot.amount > 1 :#or slot.amount != null:
			amount_text.text = str(slot.amount)
			amount = slot.amount
			amount_text.visible = true
		filled = true
		item_visual.visible = true

func _on_gui_input(event: InputEvent):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
	if event is InputEventMouseButton and event.double_click:
		print("You selected:", self.name, " On GUI Double Click")
		
		if multi_handler:
			
			var data : Dictionary
			data["SlotData"] = slotData
			data["Slot"] = self
			data["inv"] = inv
			
			multi_handler.moveDoubleClick(data)
			tooltiphandler.hide_tooltip()

func hide_slot_visual():
	item_visual.visible = false
	amount_text.visible = false
	amount_text.text = ""
	
func hide_main_slot_visual():
	mainslot.visible = false
	
func show_slot_visual():
	item_visual.visible = true
	amount_text.visible = true
	
func show_main_slot_visual():
	mainslot.visible = true

func OpenCloseSlotSwitch(newState: bool):
	isClosed = newState
	OpenCloseSlotGraphics()

func OpenCloseSlotGraphics():
	visual_closed.visible = isClosed
	visual_open.visible = !isClosed
	if !filled and !isClosed and use_visual_unfilled:
		visual_unfilled.visible = true
	else:
		visual_unfilled.visible = false

func RemoveSlotData():
	hide_slot_visual()
	item_visual.texture = null
	slotData = null
	filled = false
	amount = 0
	amount_text.text = ""

func _get_drag_data(at_position):
	if !input_handler.item_dragging_can_start():
		return
	
	#var preview_texture = instancedObject.instantiate()
	#preview_texture.update(slotData)
	#preview_texture.frame.visible = false
	
	var preview_texture = TextureRect.new()
	
	preview_texture.texture = item_visual.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(32,32)
	
	var data : Dictionary
	data["SlotData"] = slotData
	data["Slot"] = self
	data["inv"] = inv
	
	var preview = Control.new()
	preview.add_child(preview_texture)
	preview.z_index = 1

	set_drag_preview(preview)
	
	hide_slot_visual()
	tooltiphandler.hide_tooltip()
	
	dragging = true
	input_handler.item_dragging_take_control()
	
	return data

func _can_drop_data(at_position, data):
	if is_legal_drop(data):
		if is_legal_at_index(data):
			return true
	return false

func is_legal_at_index(data) -> bool:
	if(inv.Check_Addable_at_Index(data["SlotData"],index)):
			return true
	else:
		return false

func is_legal_drop(data) -> bool:
	if data is Dictionary:
		if data["SlotData"] == null:
			return false
		if data["Slot"] == null:
			return false
		if data["Slot"] == self:
			return false
		if data["inv"] == null:
			return false
		if dragging:
			return false
		if isClosed:
			return false
	else:
		return false
	return true

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if dragging and filled:
				if !is_drag_successful():
					show_slot_visual()
					update(slotData)
				dragging = false
				input_handler.item_dragging_release()

func _drop_data(at_position, data):
	
	inv.Add_Slot_at_Index(data["SlotData"],index)
	data["inv"].Remove_at_Index(data["Slot"].index)
	data["Slot"].RemoveSlotData()
	
	data["Slot"].dragging = false
	dragging = false
	filled = true
	input_handler.item_dragging_release()

func _on_mouse_entered():
	if filled and !dragging:
		tooltiphandler.setToolTipName(slotData.Item.name)
		tooltiphandler.setToolTipDesc("")
		tooltiphandler.setToolTipLore(slotData.Item.lore)
		tooltiphandler.setToolTipRank(slotData.Item.rank)
		tooltiphandler.show_tooltip()
	
func _on_mouse_exited():
	if filled:
		tooltiphandler.hide_tooltip()

func _on_hidden():
	if tooltiphandler:
		tooltiphandler.hide_tooltip()

func is_dragging() -> bool:
	return dragging

func is_filled() -> bool:
	return filled
	
func is_closed() -> bool:
	return isClosed

func setUse_visual_unfilled(useNew: bool):
	use_visual_unfilled = useNew
