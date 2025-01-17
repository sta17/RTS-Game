extends Timer

var currentTarget: Node3D

var canAttack:bool = true

var attackDamage:float

func _on_ready():
	timeout.connect(attackTimerCOOLDOWN)

func Attack() -> bool:
	if  !currentTarget==self and ((currentTarget is StaticBody3D) or (currentTarget is CharacterBody3D)):
		if currentTarget.player_object.has_method("TakeDamage") and canAttack:
			var result = currentTarget.player_object.TakeDamage(attackDamage)
			start()
			canAttack = false
			return result
	return false

func attackTimerCOOLDOWN():
	canAttack = true
	stop()

func setAttackCOOLDOWN(cooldown: float) -> void:
	wait_time = cooldown
	
func setAttackDamage(damage: float) -> void:
	attackDamage = damage

func setcurrentTarget(target: Node3D) -> void:
	currentTarget = target
