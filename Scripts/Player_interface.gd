@icon("res://Assets/Mine/UI.svg")
extends Control
class_name player_interface

#region Variables
# PRELOAD
const module_camera:GDScript = preload("res://Scripts/module_camera.gd")

#region Cursors
@export var default_cursor: Texture
@export var coin_cursor: Texture
@export var book_cursor: Texture
@export var bottle_cursor: Texture
@export var setting_cursor: Texture
@export var cross_cursor: Texture
@export var compass_cursor: Texture
#endregion

#region Node Variable Paths
@export var CameraBasePath:NodePath
@export var ui_dragboxPath:NodePath
@export var ui_order_animplayerPath:NodePath

@export var panelSectionsPath:NodePath

@export var node_building_placerPath:NodePath
@export var tooltipPath:NodePath
@export var mainMenuSectionPath:NodePath

@export var interface_btn_buildingPath:NodePath

@export var selectionSlotsContainerPath:NodePath
@export var statDisplayPath:NodePath
@export var itemSlotsContainerPath:NodePath
@export var dropItemGroundPath:NodePath

@export var characterInventoryDisplayPath:NodePath
@export var HeroSlotsContainerPath:NodePath

@export var actionSlotsContainerPath:NodePath
#endregion

#region Node Variables
@onready var CameraBase:Node3D = get_node(CameraBasePath)
@onready var ui_dragbox:NinePatchRect = get_node(ui_dragboxPath)
@onready var ui_order_animplayer:AnimationPlayer = get_node(ui_order_animplayerPath)

@onready var panelSections:Control = get_node(panelSectionsPath)

@onready var node_building_placer:Node3D = get_node(node_building_placerPath)
@onready var tooltip:Control = get_node(tooltipPath)
@onready var mainMenuSection:Control = get_node(mainMenuSectionPath)

@onready var interface_btn_building:Button = get_node(interface_btn_buildingPath)

@onready var selectionSlotsContainer:GridContainer = get_node(selectionSlotsContainerPath)
@onready var statDisplay:Control = get_node(statDisplayPath)
@onready var itemSlotsContainer:GridContainer = get_node(itemSlotsContainerPath)
@onready var dropItemGround:Panel = get_node(dropItemGroundPath)
@onready var characterInventoryDisplay:Control = get_node(characterInventoryDisplayPath)
@onready var HeroSlotsContainer:GridContainer = get_node(HeroSlotsContainerPath)
@onready var actionSlotsContainer:GridContainer = get_node(actionSlotsContainerPath)

#endregion

#region Selection Variables
@onready var selection:Array = []
@onready var selectionSlots: Array = []

var AOE:Area3D

var display_object:Object

@onready var heroDisplay:Array = []
@onready var heroDisplaySlots: Array = []
@export var displayInventory:Inv
@onready var itemSlots: Array = []

@onready var actionSlots: Array = []
#endregion

#region General Variables
const ui_min_drag_squared: int =50
const ui_min_single_selected: int = ui_min_drag_squared
const range_min_from_loc:float = -1.5
const range_max_from_loc:float = 1.5
var _building_placer_location:Vector3 = Vector3.ZERO
var selectionDisplayMax:int = 20
var drag_rectangle_area:Rect2

@export var player:faction:
	get:
		return player
	set(value):
		player = value
		hero_display_add_array(player.heros)

@export var currentScene:Node3D
#endregion

#region Booleans
var mouse_left_click:bool = false
var hold_shift_click:bool = false
var mouse_over_ui:bool = false
var _building_placer_can_place:bool = false
var is_main_menu_open:bool = false
var isTooltipDownwards:bool = true
var is_character_inventory_open:bool = false
var can_drag:bool = true
#endregion
#endregion

#region Input State
enum INPUT_STATE {
	IDLE,
	DRAGBOX_SELECTION,
	BUILDING_PLACEMENT,
	STOPPED_INPUT,
	#UI_OPEN,
	UI_OPEN_MAINMENU,
	UI_OPEN_INVENTORY,
	DRAGGING_ITEM
}
var _INTERFACE_INPUT_STATE:INPUT_STATE = INPUT_STATE.IDLE:
	set(new_value):
		
		#DEBUGGER:
		#print(
			#"Input_state_set: from ",
			#INPUT_STATE.keys()[_INTERFACE_INPUT_STATE],
			#" to ",
			#INPUT_STATE.keys()[new_value] )
		
		#EXIT
		input_state_exit(_INTERFACE_INPUT_STATE)
		
		_INTERFACE_INPUT_STATE = new_value
		
		#ENTER
		input_state_enter(new_value)
	get:
		return _INTERFACE_INPUT_STATE

func input_state_exit(STATE:int) -> void:
	match STATE:
		INPUT_STATE.BUILDING_PLACEMENT:
			node_building_placer.hide()
			node_building_placer.disable_area()
		INPUT_STATE.DRAGBOX_SELECTION:
			mouse_left_click = false
			ui_dragbox.visible = false

func input_state_enter(STATE:int) -> void:
	match STATE:
		INPUT_STATE.BUILDING_PLACEMENT:
			node_building_placer.show()
			node_building_placer.enable_area()
		INPUT_STATE.DRAGBOX_SELECTION:
			ui_dragbox.visible = true
			can_drag = false
		INPUT_STATE.IDLE:
			can_drag = true
		#INPUT_STATE.UI_OPEN:
		#	can_drag = true
		INPUT_STATE.UI_OPEN_MAINMENU:
			can_drag = true
		INPUT_STATE.UI_OPEN_INVENTORY:
			can_drag = true

func item_dragging_can_start()	-> bool:
	return can_drag

func item_dragging_take_control()-> void:
	_INTERFACE_INPUT_STATE = INPUT_STATE.DRAGGING_ITEM
	
func item_dragging_release()-> void:
	_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE
#endregion

#region General
func _ready():	
	initalize_interface()
	update_cursor()
	selectionSlots = selectionSlotsContainer.get_children()
	
	for i in range(0,selectionSlots.size()):
		selectionSlots[i].disableButton()
		selectionSlots[i].index = i
		selectionSlots[i].listener = self

	heroDisplaySlots = HeroSlotsContainer.get_children()
	
	for i in range(0,heroDisplaySlots.size()):
		heroDisplaySlots[i].disableButton()
		heroDisplaySlots[i].index = i
		heroDisplaySlots[i].listener = self

	itemSlots = itemSlotsContainer.get_children()
	actionSlots = actionSlotsContainer.get_children()
	
	clearInventyoryDisplay()
	
	if displayInventory:
		displayInventory.update.connect(update_slots_inventory)
	for i in range(0,itemSlots.size()):
		itemSlots[i].index = i
		itemSlots[i].inv = displayInventory
		itemSlots[i].multi_handler = self
		itemSlots[i].tooltiphandler = tooltip
		#itemSlots[i].OpenCloseSlotSwitch(false)

	for i in range(0,actionSlots.size()):
		actionSlots[i].index = i
		actionSlots[i].multi_handler = self
		actionSlots[i].tooltiphandler = tooltip

	dropItemGround.input_handler = self
	
	closeUI()

func update_cursor():
	# USED FOR SCALING CURSOR
	#var current_window_size_Width = ProjectSettings.get_setting("display/window/size/viewport_width")
	#var current_window_size_Height = ProjectSettings.get_setting("display/window/size/viewport_height")
	#var scale_multiple = current_window_size_Width / current_window_size_Height

	#AVAILABLE CURSORS

	#default_cursor
	#coin_cursor
	#book_cursor
	#bottle_cursor
	#setting_cursor
	#cross_cursor
	#compass_cursor

	#							  CURSOR TO USE		  USE CASE		  ARROW TIP
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW,Vector2(7, 6))
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_CAN_DROP,Vector2(7, 6))
	#								TODO: NO ACTION / CROSS
	Input.set_custom_mouse_cursor(cross_cursor, Input.CURSOR_FORBIDDEN,Vector2(7, 6))

func place_button() -> void:
	match _INTERFACE_INPUT_STATE:
		INPUT_STATE.BUILDING_PLACEMENT:
			_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE
		INPUT_STATE.IDLE:
			_INTERFACE_INPUT_STATE = INPUT_STATE.BUILDING_PLACEMENT

func _physics_process(delta: float) -> void:
	if _INTERFACE_INPUT_STATE == INPUT_STATE.BUILDING_PLACEMENT:
		var mouse_pos:Vector2 = get_global_mouse_position()
		var camera:Camera3D = get_viewport().get_camera_3d()
			
		var ray_from:Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_to:Vector3 = ray_from + camera.project_ray_normal(mouse_pos) * 1000.0
		var ray_param:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
		ray_param.collision_mask = 0b10
			
		#node_building_placer.model_red()
		var raycasted_result:Variant = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_param)
		if raycasted_result:
			if node_building_placer.transform.origin != raycasted_result.position:
				#var newLoc:Vector3 = raycasted_result.position + Vector3(0,0.5,0)
				var newLoc:Vector3 = raycasted_result.position
				node_building_placer.transform.origin = newLoc
				node_building_placer.show()
				if node_building_placer.placement_check():
					_building_placer_location = raycasted_result.position
					_building_placer_can_place = true
					node_building_placer.model_green()
				else:
					_building_placer_can_place = false
					_building_placer_location = Vector3.ZERO
					node_building_placer.model_red()
	else:
		_building_placer_can_place = false
		_building_placer_location = Vector3.ZERO

func can_place_building() -> void:
	var mouse_pos:Vector2 = get_global_mouse_position()
	var camera:Camera3D = get_viewport().get_camera_3d()
			
	var ray_from:Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_to:Vector3 = ray_from + camera.project_ray_origin(mouse_pos) * 1000.0
	var ray_param:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
	ray_param.collision_mask = 0b10
	
	node_building_placer.model_red()
	var raycasted_result:Variant = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_param)
	if raycasted_result:
		if node_building_placer.transform.origin != raycasted_result.position:
			node_building_placer.transform.origin = raycasted_result.position
			node_building_placer.show()
			if node_building_placer.placement_check():
				_building_placer_location = raycasted_result.position
				_building_placer_can_place = true
			else:
				_building_placer_can_place = false
				_building_placer_location = Vector3.ZERO

func initalize_interface() -> void:
	input_state_exit(INPUT_STATE.IDLE)
	input_state_exit(INPUT_STATE.BUILDING_PLACEMENT)
	input_state_exit(INPUT_STATE.DRAGBOX_SELECTION)
	mouse_left_click = false
	_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE
	
	AOE = CameraBase.getVisibleCamera_AOE()
	interface_btn_building.pressed.connect(place_button)

func _process(delta) -> void:
	match _INTERFACE_INPUT_STATE:
		INPUT_STATE.DRAGBOX_SELECTION:
			if mouse_left_click and !mouse_over_ui:
		
				drag_rectangle_area.size = get_global_mouse_position() -drag_rectangle_area.position
				update_ui_dragbox()
		
				if !ui_dragbox.visible:
					if drag_rectangle_area.size.length_squared() > ui_min_drag_squared:
						ui_dragbox.visible = true
		INPUT_STATE.BUILDING_PLACEMENT:
			var mouse_pos:Vector2 = get_viewport().get_mouse_position()
			var cam:Camera3D = self.get_viewport().get_camera_3d()
			var camera_raycast_coords:Vector3 = module_camera.get_vector3_from_camera_raycast(cam,mouse_pos)
		
			node_building_placer.transform.origin = camera_raycast_coords

	# Make tooltip location same as mouse location
	if tooltip.visible:
		SetTooltipPosition()
		mouse_over_ui = true

func closeUI():
	closeMainMenu()
	closeCharacterInventory()
	tooltip.hide_tooltip()

func set_location(location:Vector3):
	CameraBase.set_location(location)

func SetTooltipPosition() -> void:
	tooltip.position = get_global_mouse_position()
	tooltip.position = tooltip.position + Vector2(6,8)
		
	var yCor:int
	var xCor:int
	if tooltip.position.y + tooltip.size.y > get_viewport().get_visible_rect().size.y:
		yCor = tooltip.size.y
	if tooltip.position.x + tooltip.size.x > get_viewport().get_visible_rect().size.x:
		xCor = tooltip.size.x
	tooltip.position = tooltip.position - Vector2(xCor,yCor)
#endregion

#region Input
func _input(event: InputEvent) -> void:
	var shift:bool = event.is_action_pressed("shift_action")
	if shift:
		hold_shift_click = true
	var shift2:bool = event.is_action_released("shift_action")
	if shift2:
		hold_shift_click = false
	match _INTERFACE_INPUT_STATE:
		INPUT_STATE.IDLE:
			idle_input_handling(event)
		INPUT_STATE.BUILDING_PLACEMENT:
			building_input_handling(event)
		INPUT_STATE.DRAGBOX_SELECTION:
			dragbox_input_handling(event)
		INPUT_STATE.UI_OPEN_MAINMENU:
			ui_input_handling(event)
		INPUT_STATE.UI_OPEN_INVENTORY:
			ui_input_handling(event)
		
	#if Input.is_action_just_pressed("cancel"):
	#	closeUI()
	#	_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE
	#elif event.is_action_released("cancel"):
	#	closeUI()
	#	_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed: # only pressed events, ignore released events.
			match _INTERFACE_INPUT_STATE:
				INPUT_STATE.BUILDING_PLACEMENT: #Exit building Mode if any input.
					_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE
					get_viewport().set_input_as_handled()

func building_input_handling(event: InputEvent) -> void:
	if event.is_action_released("mouse_left_click"):
		var shift:bool = Input.is_action_pressed("shift_action")
	
		#can_place_building()
		if _building_placer_can_place and _building_placer_location != Vector3.ZERO:
			var building_packed_scane:PackedScene = load("res://Scenes/Unit/building_02.tscn")
			var building_node:Node3D = building_packed_scane.instantiate()
			get_parent().add_child(building_node)
			building_node.transform.origin = _building_placer_location
			building_node.ConnectLowerNode()
			building_node.player = player
			var newResource:Unit_data = load("res://Scenes/Unit/Test Building.tres")
			building_node.object_data = newResource
			building_node.setup()
			
			AOE.Add(building_node)
			
			if !shift: # RESET BACK TO UNIT MODE.
				_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE

func idle_input_handling(event: InputEvent) -> void:
	if Input.is_action_pressed("mouse_left_click") and !mouse_over_ui:
		drag_rectangle_area.position = get_global_mouse_position()
		ui_dragbox.position = drag_rectangle_area.position
		mouse_left_click = true
		_INTERFACE_INPUT_STATE = INPUT_STATE.DRAGBOX_SELECTION
	elif Input.is_action_pressed("mouse_right_click") and !mouse_over_ui: # MOVE UNIT ORDER
		if !selection.is_empty():
		
			var mouse_pos:Vector2 = get_viewport().get_mouse_position()
			var cam:Camera3D = self.get_viewport().get_camera_3d()
			var camera_raycast_coords:Vector3 = module_camera.get_vector3_from_camera_raycast(cam,mouse_pos)
			var target:Node3D = module_camera.get_collider_from_camera_raycast(cam,mouse_pos)
	
			if AOE.validTarget(target):
				for unit in selection:
					if unit.has_method("move_to_unit"):
						unit.move_to_unit(target)
						ui_map_location_order(target.transform.origin)
						#if target is UnitV4 or BuildingV2:
							#if unit.player == target.player:
								#target.selectPlayerFlash()
							#else:
								#target.selectEnemyFlash()
			elif camera_raycast_coords != Vector3.ZERO:
				for unit in selection:
					if unit.has_method("move_unit"):
						unit.move_unit(camera_raycast_coords)
						ui_map_location_order(camera_raycast_coords)
	
	elif Input.is_action_just_pressed("menu"):
		menu_input_handling(event)
	elif Input.is_action_just_pressed("inventory"):
		inventory_input_handling(event)

func ui_input_handling(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu"):
		menu_input_handling(event)
	elif Input.is_action_just_pressed("inventory"):
		inventory_input_handling(event)

func dragbox_input_handling(event: InputEvent) -> void:
	if event.is_action_released ("mouse_left_click") and !mouse_over_ui: # This runs just once.
		if !hold_shift_click:
			selection_clear()
		mouse_left_click = false
		ui_dragbox.visible = false

		#var shift:bool = event.is_action_pressed("shift_action")
		if drag_rectangle_area.size.length_squared() > ui_min_drag_squared:
			selection_drag_box_cast(hold_shift_click)
		else: #Single Selection Mode
			selection_single_cast(get_global_mouse_position(),hold_shift_click)
		_INTERFACE_INPUT_STATE = INPUT_STATE.IDLE

func menu_input_handling(event:InputEvent) -> void:
	# do cancel command first
	if _INTERFACE_INPUT_STATE == INPUT_STATE.UI_OPEN_MAINMENU or _INTERFACE_INPUT_STATE == INPUT_STATE.UI_OPEN_INVENTORY:
		# Do unpause
		closeUI()
		closeMainMenu()
		_INTERFACE_INPUT_STATE= INPUT_STATE.IDLE
	else:
		# Do pause also
		closeUI()
		openMainMenu()
		_INTERFACE_INPUT_STATE = INPUT_STATE.UI_OPEN_MAINMENU

func inventory_input_handling(event:InputEvent) -> void:
	if _INTERFACE_INPUT_STATE == INPUT_STATE.UI_OPEN_MAINMENU:
		return
	elif _INTERFACE_INPUT_STATE == INPUT_STATE.UI_OPEN_INVENTORY:
		# Do unpause
		closeCharacterInventory()
		_INTERFACE_INPUT_STATE= INPUT_STATE.IDLE
	else:
		# Do pause also
		closeUI()
		openCharacterInventory()
		_INTERFACE_INPUT_STATE = INPUT_STATE.UI_OPEN_INVENTORY

func selection_button(index: int):
	var unit = selection[index]
	if unit:
		selection_single_button(unit,hold_shift_click)

func ui_map_location_order(loc:Vector3) -> void:
	ui_order_animplayer.stop()
	ui_order_animplayer.play("move_order")
	(ui_order_animplayer.get_parent() as Node3D).transform.origin = loc

#endregion

#region Selection

func selection_single_button(unit,shift:bool = false) -> void:
	if !shift:
		selection_clear()
		selection_add(unit)
	elif shift:
		updateDisplay(unit)

func selection_single_cast(mouse_2D_pos:Vector2,shift:bool = false) -> void:
	if !mouse_over_ui:	
		for unit in AOE.getTargetsArray():
			#var unit_2D_pos:Vector2 = player_camera.unproject_position((unit as Node3D).transform.origin + Vector3(0,0.85,0))
			var unit_2D_pos:Vector2 = CameraBase.getPlayerCamera().unproject_position((unit as Node3D).transform.origin + Vector3(0,0.5,0))	
			if(mouse_2D_pos.distance_to(unit_2D_pos)) < ui_min_single_selected:
				if shift:
					selection_add(unit)
					return
				else:
					selection_select_array([unit])
					return
		selection_clear()

func selection_drag_box_cast(shift_enabled:bool = false) -> void:
	if !shift_enabled:selection_clear()
	for unit in AOE.getTargetsArray():
		if drag_rectangle_area.abs().has_point(CameraBase.getPlayerCamera().unproject_position(unit.transform.origin)):
			selection_add(unit)

func selection_add_array(units_to_add:Array) -> void:
	for unit in units_to_add:
		selection_add(unit)

func selection_add(unit) -> void:
	if !selection.has(unit) and ((unit is StaticBody3D) or (unit is CharacterBody3D)):
		if selection.size() == 0:
			updateDisplay(unit)
		if unit is BuildingV2 or unit is UnitV4:
			if !unit.player == player:
				return
		selection.append(unit)
		unit.setSelected(true)
		if selection.size()-1 < selectionDisplayMax:
			selectionSlots[selection.size()-1].changeIcon(unit.GetIcon())
		# get index for unit? or sort selection list by unit type?
		
		# sort by unit_data id
		if selection.size() > 1:
			selection.sort_custom(sort_unit_data_selection)
			var j = selection.size()
			for i in range(0,j):
				var seltemp = selection[i]
				var temp = seltemp.GetIcon()
				selectionSlots[i].changeIcon(temp)
	elif !selection.has(unit) and unit is CollectibleItem2D:
		updateDisplay(unit)

func selection_remove_at(index:int,unit) -> void:
	selection.remove_at(index)
	unit.setSelected(false)
	selectionSlots[index-1].disableButton()
	# Redo / Update the visuals
	# func.something
	if selection.size() == 0:
		clearDisplay()
		clearInventyoryDisplay()
		clearActionDisplay()

func selection_remove(unit_to_remove:Node3D) -> void:
	var i:int = 0
	for unit in selection:
		if unit_to_remove == unit:
			selection_remove_at(i,unit_to_remove)
			break
		i += 1

func selection_remove_array(units_to_remove:Array) -> void:
	var i:int = 0
	for unit in selection:
		for unit_to_remove in units_to_remove:
			if unit == unit_to_remove:
				selection_remove_at(i,unit)
				break # found a unit that matches, remove it
		i += 1

func selection_toggle_select(unit) -> void:
	if unit.GetSelected():
		selection_remove(unit)
	else:
		selection_add(unit)

func selection_select_array(units_to_select:Array) -> void:
	selection_clear()
	var i:int = 0
	for unit_to_select in units_to_select:
		if !unit_to_select.GetSelected():
			selection_add(unit_to_select)
		else:
			selection_remove_at(i,unit_to_select)
		i += 1
		
func selection_clear()-> void:
	for unit in selection:
		unit.setSelected(false)
	for i in range(0,selectionSlots.size()):
		selectionSlots[i].disableButton()
	
	selection = []
	clearDisplay()
	clearInventyoryDisplay()
	clearActionDisplay()
	characterInventoryDisplay.Clear()

func update_ui_dragbox() -> void:
	ui_dragbox.size = abs(drag_rectangle_area.size)

	if drag_rectangle_area.size.x < 0:
			ui_dragbox.scale.x = -1
	else: 	ui_dragbox.scale.x = 1	

	if drag_rectangle_area.size.y < 0:
			ui_dragbox.scale.y = -1
	else:	ui_dragbox.scale.y = 1	

func sort_unit_data_selection(a, b):
	if (a.player_object.object_data is Hero_data) and (b.player_object.object_data is Hero_data):
		return false
	if a.player_object.object_data is Hero_data:
		return true
	elif a.player_object.object_data.get_instance_id() > b.player_object.object_data.get_instance_id():
		if b.player_object.object_data is Hero_data:
			return false
		return true
	return false
#endregion

#region Hero Selection

func hero_display_button(index: int):
	var unit = heroDisplay[index]
	selection_single_button(unit,hold_shift_click)

func hero_display_remove_at(index:int,unit) -> void:
	heroDisplay.remove_at(index)
	heroDisplaySlots[index-1].disableButton()

	if heroDisplay.size() == 0:
		clearDisplay()
		clearInventyoryDisplay()
		clearActionDisplay()

func hero_display_remove(unit_to_remove:Node3D) -> void:
	var i:int = 0
	for unit in heroDisplay:
		if unit_to_remove == unit:
			hero_display_remove_at(i,unit_to_remove)
			break
		i += 1

func hero_display_add_array(units_to_add:Array) -> void:
	for unit in units_to_add:
		hero_display_add(unit)

func hero_display_add(unit) -> void:
	if !heroDisplay.has(unit) and unit is UnitV4:
		heroDisplay.append(unit)
		heroDisplaySlots[heroDisplay.size()-1].changeIcon(unit.GetIcon())
		
		# sort by unit_data id
		if heroDisplay.size() > 1:
			heroDisplay.sort_custom(sort_unit_data_selection)
			for i in range(0,min(heroDisplaySlots.size(),heroDisplay.size())-1):
				var seltemp = heroDisplay[i]
				var temp = seltemp.GetIcon()
				heroDisplaySlots[i].changeIcon(temp)
				heroDisplaySlots[i].enableButton()

#endregion

#region StatsDisplay
func updateDisplay(object)	-> void:
	display_object = object
	clearDisplay()
	clearInventyoryDisplay()
	clearActionDisplay()
	#determin type of object
	# if hero
	if object is UnitV4:
		if object.player_object.object_data is Hero_data:
			statDisplay.ShowHero(object.player_object)
			SetDisplayInventory(object.player_object.personalInventory)
			updateCharacterInventory()
			update_slots_Action()
		elif object.player_object.object_data is Unit_data:
			statDisplay.ShowUnit(object.player_object)
			SetDisplayInventory(object.player_object.personalInventory)
			update_slots_Action()
	elif object is BuildingV2:
		statDisplay.ShowUnit(object.player_object)
		SetDisplayInventory(object.player_object.personalInventory)
	elif object is CollectibleItem2D:
		var tempItem = object.item
		statDisplay.ShowItem(tempItem)
	
func clearDisplay()	-> void:
	statDisplay.HideHero()
	statDisplay.HideUnit()
	statDisplay.HideItem()
#endregion

#region ActionDisplay
func update_slots_Action():
	for i in actionSlots.size():
		if i < display_object.object_data.actions.size():
			actionSlots[i].update(display_object.object_data.actions[i])
		else:
			actionSlots[i].update(null)
		actionSlots[i].input_handler = self

func clearActionDisplay()	-> void:
	for i in range(0,actionSlots.size()):
		actionSlots[i].RemoveSlotData()
#endregion

#region InventoryDisplay
func update_slots_inventory():
	for i in range(min(displayInventory.slots.size(),itemSlots.size())):
		itemSlots[i].show_main_slot_visual()
		itemSlots[i].inv = displayInventory
		itemSlots[i].update(displayInventory.slots[i])
		itemSlots[i].input_handler = self
		itemSlots[i].OpenCloseSlotSwitch(false)

func clearInventyoryDisplay()	-> void:
	for i in range(0,itemSlots.size()):
		itemSlots[i].RemoveSlotData()
		itemSlots[i].hide_main_slot_visual()
		itemSlots[i].OpenCloseSlotSwitch(true)

func SetDisplayInventory(newInv:Inv):
	if displayInventory:
		displayInventory.update.disconnect(update_slots_inventory)
	displayInventory = newInv
	if newInv:
		displayInventory.update.connect(update_slots_inventory)
		update_slots_inventory()
#endregion

#region Over UI
func _on_panel_mouse_entered():
	mouse_over_ui = true

func _on_panel_mouse_exited():
	mouse_over_ui = false

func _on_bottom_ui_panel_mouse_entered():
	mouse_over_ui = true

func _on_bottom_ui_panel_mouse_exited():
	mouse_over_ui = false

#endregion

#region Main Menu
func _on_option_button_pressed():
	pass # Replace with function body.

func _on_save_button_pressed():
	pass # Replace with function body.

func _on_exit_button_pressed():
	get_tree().quit()

func openMainMenu():
	mainMenuSection.visible = true
	is_main_menu_open = true

func closeMainMenu():
	mainMenuSection.visible = false
	is_main_menu_open = false
#endregion

#region Character Inventory
func openCharacterInventory():
	characterInventoryDisplay.visible = true
	is_character_inventory_open = true

func closeCharacterInventory():
	characterInventoryDisplay.visible = false
	is_character_inventory_open = false

func updateCharacterInventory():
	characterInventoryDisplay.setDisplay(display_object,displayInventory)

#endregion
