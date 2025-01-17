extends Node3D

var next_scene = null
var spawn_point = null
@onready var current_scene_holder:Node3D = $CurrentScene
@onready var ui = $Player_interface

var player_mode
var scene

var startTransition: bool = false
var startNewScene:bool = false

var startNewSceneNoFade:bool = false

func _ready():
	$"Fade to Black/NinePatchRect".visible = false

func transition_to_scene(new_scene:String,goto_point:String=""):
	next_scene = new_scene
	spawn_point = goto_point
	
	#transition_to_sceneWithOutFade(new_scene,goto_point)
	$"Fade to Black/AnimationPlayer".play("FadeToBlack")
	
func _process(delta):
	if startTransition:
		HandleOldScene()
	elif(startNewScene):
		StartNewScene()
	elif(startNewSceneNoFade):
		transition_to_sceneWithOutFade_NextStage()
	
func AfterFadeToBlack():
	startTransition = true
	
func HandleOldScene():
	# Change transition code here.
	var localSceneHandler = current_scene_holder.get_child(0)
	localSceneHandler.queue_free()

	scene = load(next_scene).instantiate()
	
	var area_Name:String = scene.Area_Display_Name[spawn_point]
	area_Name = "  " + area_Name
	$"Fade to Black/NinePatchRect/Panel/Label".text = area_Name
	
	# Set Player Location in scene,
	var player_spawn_point:Vector3 = scene.get_spawn_point(spawn_point)
	ui.set_location(player_spawn_point)
	
	startTransition = false
	startNewScene = true

func StartNewScene():
	current_scene_holder.add_child(scene)

	$"Fade to Black/AnimationPlayer".play("FadeToNormal")

func AfterFateToNormal():
	startNewScene = false
	$"Fade to Black/AnimationPlayer".play("Show Sign")

func displayAreaName():
	$"Fade to Black/AnimationPlayer".play("Show Sign")

func transition_to_sceneWithOutFade(new_scene:String,factionName:String,goto_point:String=""):
	next_scene = new_scene
	spawn_point = goto_point
	
	# Change transition code here.
	var localSceneHandler = current_scene_holder.get_child(0)
	localSceneHandler.queue_free()

	scene = load(next_scene).instantiate()
	
	# Set Player Location in scene,
	var player_spawn_point:Vector3 = scene.get_spawn_point(spawn_point)
	ui.set_location(player_spawn_point)
	
	var fac = scene.getPlayer(factionName)
	ui.player = fac
	fac.ui = ui
	ui.currentScene = scene
	
	current_scene_holder.add_child(scene)
	
	startNewSceneNoFade = true

func transition_to_sceneWithOutFade_NextStage():
	current_scene_holder.add_child(scene)
	startNewSceneNoFade = false

func On():
	# turn player on again.
	ui.set_process(true)
	ui.set_process_input(true)
	get_tree().paused = false
	ui.start_inputs()
	current_scene_holder.set_block_signals(false)
	ui.visible = true
	ui.process_mode = player_mode

func Off():
		# turn player off to prevent triggering things.
	ui.stop_inputs()
	ui.set_process(false)
	ui.set_process_input(false)
	ui.visible = false
	player_mode = ui.process_mode
	ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = true
	current_scene_holder.set_block_signals(true)
