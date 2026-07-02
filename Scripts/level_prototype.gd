extends Node2D

enum State {
	IDLE,
	WAIT_FOR_PARRY,
	WAIT_FOR_FIRST_COUNTER,
	WAIT_FOR_SECOND_COUNTER
}

var state = State.IDLE

var attack_start_time: float
var parry_time: float
var first_counter_time: float


func _ready() -> void:
	start_enemy_attack()


func start_enemy_attack():
	state = State.WAIT_FOR_PARRY
	attack_start_time = Time.get_ticks_msec() / 1000.0
	$Control/Label.text = ""
	$ParryTimer.start()
	$Control/ActionCommandButton.visible = true
	$EnemyAnimationPlayer.play("Anim_EnemyAttack")


func _input(event):
	if event.is_action_pressed("action_button"):
		match state:
			State.WAIT_FOR_PARRY:
				try_parry()
			State.WAIT_FOR_FIRST_COUNTER:
				try_first_counter()
			State.WAIT_FOR_SECOND_COUNTER:
				try_second_counter()


func try_parry():
	var now = Time.get_ticks_msec() / 1000.0
	var elapsed = now - attack_start_time
	$PlayerAnimationPlayer.play("Anim_PlayerParry")
	
	if elapsed >= 0.85 && elapsed <= 1.15:
		$Control/Label.text = "nice!"
		start_first_counter()
	if elapsed < 0.85:
		$Control/Label.text = "too early (" + str(snapped(0.85 - elapsed, 0.01)) + "s)"
		print("Parry failed (pressed at " + str(elapsed) + ")")
	if elapsed > 1.15:
		$Control/Label.text = "too late (" + str(snapped(elapsed - 1.15, 0.01)) + "s)"
		print("Parry failed (pressed at " + str(elapsed) + ")")


func _on_parry_timer_timeout() -> void:
	if state == State.WAIT_FOR_PARRY:
		print("Parry failed (timeouted)")
		$PlayerAnimationPlayer.play("Anim_PlayerHurt")
		reset()


func start_first_counter():
	state = State.WAIT_FOR_FIRST_COUNTER
	parry_time = Time.get_ticks_msec() / 1000.0
	$FirstCounterTimer.start()
	$EnemyAnimationPlayer.play("Anim_EnemyParried")
	$ParryFX.play("default")


func try_first_counter():
	var now = Time.get_ticks_msec() / 1000.0
	var elapsed = now - parry_time
	
	if elapsed <= 0.5:
		$Control/Label.text = "Good!"
		start_second_counter()
	else:
		$Control/Label.text = "too late (" + str(elapsed-0.5) + ")"
		print("Counter failed (pressed at " + str(elapsed) + ")")
		reset()


func _on_first_counter_timer_timeout() -> void:
	if state == State.WAIT_FOR_FIRST_COUNTER:
		$Control/Label.text = ""
		print("Counter failed (timeouted)")
		reset()


func start_second_counter():
	state = State.WAIT_FOR_SECOND_COUNTER
	first_counter_time = Time.get_ticks_msec() / 1000.0
	$SecondCounterTimer.start()
	$EnemyAnimationPlayer.play("Anim_EnemyCountered")
	$HitFX.rotation = 360 * randf()
	$HitFX.play("default")
	get_node("Camera2D").apply_shake(0.2)
	$PlayerAnimationPlayer.play("Anim_PlayerCounter")


func try_second_counter():
	var now = Time.get_ticks_msec() / 1000.0
	var elapsed = now - first_counter_time
	
	if elapsed >= 0.35 && elapsed <= 0.65:
		print("Second counter success")
		$Control/Label.text = "Great!"
		$EnemyAnimationPlayer.play("Anim_EnemyCountered2")
		$HitFX.rotation = 360 * randf()
		$HitFX.play("default")
		get_node("Camera2D").apply_shake(0.13)
		$PlayerAnimationPlayer.play("Anim_PlayerCounter2")
	if elapsed < 0.35:
		$Control/Label.text = "too early (" + str(0.35-elapsed) + "s)"
		print("Second counter failed (pressed at " + str(elapsed) + ")")
	if elapsed > 0.65:
		$Control/Label.text = "too late (" + str(elapsed-0.65) + "s)"
		print("Second counter failed (pressed at " + str(elapsed) + ")")


func _on_second_counter_timer_timeout() -> void:
	reset()


func reset():
	state = State.IDLE
	$Control/ActionCommandButton.visible = false
	print("Resetting. Ready for next attack")
	await get_tree().create_timer(2.0).timeout
	start_enemy_attack()


func _on_player_animation_player_animation_finished(anim_name):
	$PlayerAnimationPlayer.play("RESET")
