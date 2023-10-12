extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false
var time_appear = 0.5
var time_fall = 0.8
var time_rotate = 1.0
var time_a = 2
var time_s = 2
var time_v = 2
var tween

var powerup_prob = 0.1

var sway_amplitude = 1
var sway_initial_position = Vector2.ZERO
var sway_randomizer = Vector2.ZERO

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	position.x = new_position.x
	position.y = -100
	tween = create_tween()
	tween.tween_property(self, "position", new_position, 0.5 * randf()*2).set_trans(Tween.TRANS_BOUNCE)
	sway_initial_position = $Brick.position
	sway_initial_position = $Broken.position
	sway_randomizer = Vector2(randf()*4-3.0, randf()*4-3.0)

func _physics_process(_delta):
	if dying and not $Triangle.emitting and not tween:
		queue_free()
	var pos_x = (sin(Global.sway_index)*(sway_amplitude + sway_randomizer.x))
	var pos_y = (sin(Global.sway_index)*(sway_amplitude + sway_randomizer.y))
	$Brick.position = Vector2(sway_initial_position.x + pos_x, sway_initial_position.y + pos_y)
	$Broken.position = Vector2(sway_initial_position.x + pos_x, sway_initial_position.y + pos_y)


func hit(_ball):
	die()

func die():
	var Brick_Sound = get_node("/root/Game/Brick_Sound")
	Brick_Sound.play()
	dying = true
	collision_layer = 0
	$Brick.hide()
	$Triangle.emitting = true
	$Square.emitting = true
	$Circle.emitting = true
	Global.update_score(score)
	if not Global.feverish:
		Global.update_fever(score)
	get_parent().check_level()
	if randf() < powerup_prob:
		var Powerup_Container = get_node_or_null("/root/Game/Powerup_Container")
		if Powerup_Container != null:
			var Powerup = load("res://Powerups/Powerup.tscn")
			var powerup = Powerup.instantiate()
			powerup.position = position
			Powerup_Container.call_deferred("add_child", powerup)
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(position.x, 1000), time_fall).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation", -PI + randf()*2*PI, time_rotate).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Broken, "modulate:a", 0, time_a)
	tween.tween_property($Broken, "modulate:s", 0, time_s)
	tween.tween_property($Broken, "modulate:v", 0, time_v)
