extends Sprite3D

@onready var animationPlayer:AnimationPlayer = $AnimationPlayer
@onready var selectionCircle:Sprite3D = $"."

func _ready() -> void:
	setSelected(false)

var selected:bool = false#:
	#set(new_value):
	#	selected = new_value
	#	update_selected()

func setSelected(status:bool):
	selected = status
	update_selected()

func update_selected() -> void:
	if selected: selectionCircle.visible = true
	else: selectionCircle.visible = false

func setThin():
	var image_path ="res://Assets/Mine/ui_selct_circle02.png"
	setSelectionCircleGraphic(image_path)

func setThick():
	var image_path = "res://Assets/Mine/ui_selct_circle01.png"
	setSelectionCircleGraphic(image_path)

func setSelectionCircleGraphic(image_path:String):
	var image = Image.new()
	var error = image.load(image_path)
	if error != OK:
		return

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	selectionCircle.texture = texture

func selectEnemyFlash():
	# ff00004b
	modulate = Color(255,0,0)
	animationPlayer.play("Selection Flash Enemy")
	
func selectPlayerFlash():
	# 00ff004b
	modulate = Color(0,255,0)
	animationPlayer.play("Selection Flash Player")

func selectNeutralFlash():
	# ffff004b
	modulate = Color(255,255,0)
	animationPlayer.play("Selection Flash Neutral")

func selectEnemy():
	# ff00004b
	modulate = Color(255,0,0)
	
func selectPlayer():
	# 00ff004b
	modulate = Color(0,255,0)

func selectNeutral():
	# ffff004b
	modulate = Color(255,255,0)
