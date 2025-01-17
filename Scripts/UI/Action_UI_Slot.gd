extends TextureButton
class_name Action_UI_Slot

@onready var tooltiphandler

@export var index: int

var filled: bool = false

@onready var button: TextureButton = $"."
@export var icon_empty: Texture

var multi_handler: Object
var input_handler: Object

@export var slotData: ActionData

func _ready():
	button.texture_disabled = icon_empty
	fillButtonImage(icon_empty)

func update(slot: ActionData):
	if !slot:
		RemoveSlotData()
		filled = false
	else:
		slotData = slot
		fillButtonImage(slot.icon)
		button.disabled = false
		filled = true

func _on_gui_input(event: InputEvent):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
	if event is InputEventMouseButton and event.double_click:
		print("You selected:", self.name, " On GUI Double Click")
		
		if multi_handler:
			
			var data : Dictionary
			data["type"] = "action"
			data["SlotData"] = slotData
			data["Slot"] = self
			
			#multi_handler.moveDoubleClick(data)
			#tooltiphandler.hide_tooltip()

func RemoveSlotData():
	fillButtonImage(icon_empty)
	slotData = null
	button.disabled = true
	filled = false

func _on_mouse_entered():
	if filled and !button.disabled:
		tooltiphandler.setToolTipName(slotData.name)
		tooltiphandler.setToolTipLore("")
		tooltiphandler.setToolTipRank(null)
		tooltiphandler.setToolTipDesc("")
		tooltiphandler.show_tooltip()
	
func _on_mouse_exited():
	if filled:
		tooltiphandler.hide_tooltip()

func _on_hidden():
	if tooltiphandler:
		tooltiphandler.hide_tooltip()

func fillButtonImage(newText: Texture):
	button.texture_normal = newText
	button.texture_focused = newText
	button.texture_hover = newText
	button.texture_pressed = newText

func is_filled() -> bool:
	return filled

func _on_pressed():
	if filled:
		print("button ",index," ,with move ", slotData.name," has been pressed.")
		# create hook that calls the spell function and provides unit who called.
