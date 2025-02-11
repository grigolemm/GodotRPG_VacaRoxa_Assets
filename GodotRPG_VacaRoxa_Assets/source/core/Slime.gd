extends KinematicBody2D

var direction = Vector2.ZERO
var length = 0
var z = 0.1
var z_speed = 3
var hp = 100 setget set_hp, get_hp
export var red : bool

const SPEED = 45

onready var HealthBarFG = $HealthBarFG
onready var HealthBarBG = $HealthBarBG
onready var TXTDamage = $TXTDamage

func set_hp(value):
	hp += value

func get_hp():
	return hp

func _ready():
	HealthBarFG.value = hp;
	direction = (position - get_parent().get_parent().get_node("Pond").position).normalized()
	length = 250
	
	if red:
		get_node("Sprite").texture = load("res://sprites/mobs/slime-orange.png")

var motion = Vector2.ZERO

func _process(delta):
	if length > 0:
		motion = direction * length
		length *= 0.9
	
	if position.x < 0 or position.x > 320:
		direction *= -1
	if position.y < 0 or position.y > 180:
		direction *= -1
	
	if hp <= 0:
		var e = globals.EXPLOSION.instance()
		e.position = position
		e.emitting = true
		get_parent().add_child(e)
		
		get_parent().get_parent().get_node("Camera").get_node("AnimationPlayer").play("Shake")
		queue_free()
		
	if (TXTDamage.is_visible()):
		move_txt(delta)
		
	if red:
		move_to("../../Player")
	
	z += z_speed
	z_speed -= 0.2
	if z > 0:
		get_node("CollisionShape2D").disabled = true
	else:
		get_node("CollisionShape2D").disabled = false
		z = 0
	
	get_node("Sprite").position.y = -z
	motion = move_and_slide(motion)


func deal_damage(damage) -> void:
	set_hp(-damage)
	HealthBarFG.value = get_hp();
	if get_hp() > 0:
		show_hide_txt(true)
		yield(get_tree().create_timer(0.35), "timeout")
		show_hide_txt(false)
	HealthBarBG.value = get_hp();


func show_hide_txt(visible) -> void:
	TXTDamage.set_position(Vector2(-4,-14))
	TXTDamage.visible = visible


func move_txt(delta) -> void:
	TXTDamage.set_position(
		lerp(TXTDamage.get_position(), 
		Vector2(rand_range(-10, 10), rand_range(10, 20)), 
		delta))
	
	motion = move_and_slide(motion)
	get_node("ProgressBar").value = hp * 20


func _on_Hitbox_area_entered(area):
	if area.is_in_group("Stick"):
		#var txt = TEXT.instance()
		#txt.position = position
		#get_parent().add_child(txt)
		
		direction = -(area.position - position).normalized()
		length = 150
		get_node("AnimationPlayer").play("Hit")
		
		deal_damage(area.damage)
		#area.queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hit":
		get_node("AnimationPlayer").play("Bounce")
	
func move_to(path: String):
	var target_pos = get_node(path).position
	var dir = (target_pos - position).normalized()
	motion = dir * SPEED
	
