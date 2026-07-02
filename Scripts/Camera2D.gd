extends Camera2D

@export var StartShakeStrength = 15.0
var ShakeStrength = 0.0
var ShakeFade = 0.0

func apply_shake(Fade):
	ShakeStrength = StartShakeStrength
	ShakeFade = Fade


func _process(delta):
	if ShakeStrength > 0.0:
		ShakeStrength = lerpf(ShakeStrength,0,ShakeFade)
		offset = randomOffset()

func randomOffset():
	return Vector2(randf_range(-ShakeStrength,ShakeStrength),randf_range(-ShakeStrength,ShakeStrength))
