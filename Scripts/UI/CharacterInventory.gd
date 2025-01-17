@icon("res://Assets/Mine/UI.svg")
extends Control
class_name Character_Inventory

@export var statDisplayPath:NodePath
@export var itemSlotsContainerPath:NodePath
@export var tooltipPath:NodePath
@export var input_handlerPath:NodePath
@export var categorizedItemSlotsContainerPath:NodePath

@onready var statDisplay:Control = get_node(statDisplayPath)
@onready var itemSlotsContainer:GridContainer = get_node(itemSlotsContainerPath)
@onready var categorizedItemSlotsContainer:Control = get_node(categorizedItemSlotsContainerPath)
@onready var tooltip:Control = get_node(tooltipPath)
@onready var input_handler:Control = get_node(input_handlerPath)

@export var displayInventory:Inv
@export var displayEquipInventory:Inv
@onready var itemSlots: Array = []
@onready var catItemSlots: Array = []

var display_object:Object

func _ready():
	itemSlots = itemSlotsContainer.get_children()
	catItemSlots = categorizedItemSlotsContainer.get_children()
	
	#clearInventyoryDisplay()
	
	if displayInventory:
		displayInventory.update.connect(update_slots_inventory)
	if displayEquipInventory:
		displayEquipInventory.update.connect(update_equip_slots_inventory)
	for i in range(0,itemSlots.size()):
		itemSlots[i].index = i
		itemSlots[i].inv = displayInventory
		itemSlots[i].multi_handler = input_handler
		itemSlots[i].tooltiphandler = tooltip
		#itemSlots[i].OpenCloseSlotSwitch(false)
	for i in range(0,catItemSlots.size()):
		catItemSlots[i].index = i
		catItemSlots[i].set_inv(displayEquipInventory)
		catItemSlots[i].multi_handler = input_handler
		catItemSlots[i].input_handler = input_handler
		catItemSlots[i].tooltiphandler = tooltip
		catItemSlots[i].initialize()
		#catItemSlots[i].OpenCloseSlotSwitch(false)
		
	clearInventyoryDisplay()

func setDisplay(newDisplay_object:Object,newDisplayInventory:Inv):
	updateDisplay(newDisplay_object)
	SetDisplayInventory(newDisplayInventory)

func setDisplayEquipment(newDisplay_object:Object,newDisplayInventory:Inv,newdisplayEquipInventory:Inv):
	updateDisplay(newDisplay_object)
	SetDisplayEquipInventory(newDisplayInventory)

func Clear():
	clearDisplay()
	clearInventyoryDisplay()

#region StatsDisplay
func updateDisplay(object)	-> void:
	display_object = object
	clearDisplay()
	clearInventyoryDisplay()
	#determin type of object
	# if hero
	if object is UnitV4:
		if object.player_object.object_data is Hero_data:
			statDisplay.ShowHero(object.player_object)
			SetDisplayInventory(object.player_object.personalInventory)
			SetDisplayEquipInventory(object.player_object.equiptmentInventory)
		elif object.player_object.object_data is Unit_data:
			statDisplay.ShowUnit(object.player_object)
			SetDisplayInventory(object.player_object.personalInventory)
	
func clearDisplay()	-> void:
	statDisplay.HideHero()
	statDisplay.HideUnit()
	statDisplay.HideItem()
#endregion

#region InventoryDisplay
func update_slots_inventory():
	for i in range(min(displayInventory.slots.size(),itemSlots.size())):
		itemSlots[i].show_main_slot_visual()
		itemSlots[i].inv = displayInventory
		itemSlots[i].update(displayInventory.slots[i])
		itemSlots[i].input_handler = input_handler
		itemSlots[i].OpenCloseSlotSwitch(false)

func update_equip_slots_inventory():
	for i in range(min(displayEquipInventory.slots.size(),catItemSlots.size())):
		catItemSlots[i].show_main_slot_visual()
		catItemSlots[i].set_inv(displayEquipInventory)
		catItemSlots[i].update(displayEquipInventory.slots[i])
		catItemSlots[i].input_handler = input_handler
		catItemSlots[i].OpenCloseSlotSwitch(false)

func clearInventyoryDisplay()	-> void:
	for i in range(0,itemSlots.size()):
		itemSlots[i].RemoveSlotData()
		itemSlots[i].hide_main_slot_visual()
		itemSlots[i].OpenCloseSlotSwitch(true)
	for i in range(0,catItemSlots.size()):
		catItemSlots[i].RemoveSlotData()
		catItemSlots[i].hide_main_slot_visual()
		catItemSlots[i].OpenCloseSlotSwitch(true)

func SetDisplayInventory(newInv:Inv):
	if displayInventory:
		displayInventory.update.disconnect(update_slots_inventory)
	displayInventory = newInv
	if newInv:
		displayInventory.update.connect(update_slots_inventory)
		update_slots_inventory()
		
func SetDisplayEquipInventory(newInv:Inv):
	if displayEquipInventory:
		displayEquipInventory.update.disconnect(update_equip_slots_inventory)
	displayEquipInventory = newInv
	if newInv:
		displayEquipInventory.update.connect(update_equip_slots_inventory)
		update_equip_slots_inventory()
#endregion
