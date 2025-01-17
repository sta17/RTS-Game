@icon("res://Assets/Inventory Addin/node_inventory_system_base.svg")
extends Control

@export var inventorySize: int = 5

var is_single_open = false

var slots: Array
@export var inv: Inv #= preload("res://Scenes/Inventory/Player_Inventory.tres")

var tooltiphandler: Object
var multi_handler: Object

var xSize: int
var ySize: int

@onready var singleSection:NinePatchRect = $NinePatchRect

@onready var slotholder:GridContainer = $NinePatchRect/GridContainer

@onready var slot1:Control = $NinePatchRect/GridContainer/Control

func _ready():
	pass

func setup(Newtooltiphandler: Object,Newmulti_handler: Object):
	tooltiphandler = Newtooltiphandler
	if Newmulti_handler:
		multi_handler = Newmulti_handler

func rescale(invNew: Inv):
	DoDisConnect()
	inv = invNew
	
	var inventorySize: int = inv.slots.size()
	var UISize: int = slots.size()
	
	if inventorySize > UISize:
		for i in range(0,inventorySize-UISize-1):
			slotholder.add_child(slot1.duplicate())
	
	slots = slotholder.get_children()
	
	for i in range(0,max(UISize,inventorySize)):
		slots[i].RemoveSlotData()
		slots[i].hide_main_slot_visual()
	
	slotholder.visible = false
	slotholder.visible = true
	
	xSize = slotholder.size.x + 20
	ySize = slotholder.size.y + 20
	
	if xSize < 158:
		xSize = 158
	if ySize < 128:
		ySize = 128
	
	# set as chest invent size
	singleSection.size = Vector2(xSize, ySize)
	#singleSection.custom_minimum_size = Vector2(xSize, ySize)
	
	singleSection.visible = false
	singleSection.visible = true
	singleSection.visible = false
	
	DoConnect()

func DoConnect():
	inv.update.connect(update_slots_inventory)
	for i in inv.slots.size():
		slots[i].index = i
		slots[i].inv = inv
		if multi_handler:
			slots[i].multi_handler = multi_handler
		slots[i].tooltiphandler = tooltiphandler
		slots[i].show_main_slot_visual()
	update_slots_inventory()

func DoDisConnect():
	if inv:
		inv.update.disconnect(update_slots_inventory)

func update_slots_inventory():
	for i in inv.slots.size():
		slots[i].inv = inv
		slots[i].update(inv.slots[i])

func open():
	singleSection.visible = true
	is_single_open = true

func close():
	singleSection.visible = false
	is_single_open = false
