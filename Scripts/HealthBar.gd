extends Sprite3D

@onready var healthbar:ProgressBar = $SubViewport/HealthBar3D

var currentHP:float
@export var MAXHP:float

func _ready():
	healthbar = $SubViewport/HealthBar3D
	setup(MAXHP)

func setup(health: float):
	MAXHP = health
	currentHP = MAXHP
	setCurrentHP(MAXHP)

func takeDamage(damage: float) -> void:
	setCurrentHP(currentHP - damage)

func setCurrentHP(health: float) -> void:
	currentHP = health
	$SubViewport/HealthBar3D.value = currentHP
	if currentHP == MAXHP:
		$SubViewport/HealthBar3D.visible = false
	else:
		$SubViewport/HealthBar3D.visible = true

func GetCurrentHPAmount() -> float:
	return currentHP

func isDead() -> bool:
	if currentHP<=0:
		return true
	return false
