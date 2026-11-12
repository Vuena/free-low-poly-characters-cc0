extends Node3D
# Blocky Characters - Godot 4 sample.
# Builds a tiny scene from code: ground, light, camera and one character.
#   Up / Down    next / previous animation clip (all clips found in the file, in a fixed order)
#   1 - 9, 0     jump to the first ten clips (idle, walk, run, jump, fall, wave, ...)
#   Left / Right previous / next character
# Every .glb contains an AnimationPlayer with the same clips and the same names.

const CHARACTERS := ["blocky_01_hero", "blocky_03_knight", "blocky_05_wizard", "blocky_06_pirate", "blocky_07_astronaut", "blocky_08_robot", "blocky_09_zombie", "blocky_19_princess"]
# canonical order (v1.0 clips first, v1.1 clips after them)
const ORDER := ["idle", "walk", "run", "jump", "fall", "wave",
		"walk_back", "strafe_left", "strafe_right", "sprint", "crouch_idle", "crouch_walk",
		"punch", "kick", "sword_slash", "shoot", "block", "hit_react", "death", "die_idle",
		"idle_look_around", "cheer", "dance", "clap", "sit_down", "sit_idle", "interact", "push", "climb", "swim"]
# glTF clips import without looping: these are the clips that should loop
const LOOPING := ["idle", "walk", "run", "fall", "wave", "walk_back", "strafe_left", "strafe_right", "sprint", "crouch_idle", "crouch_walk",
		"shoot", "block", "die_idle", "idle_look_around", "cheer", "dance", "clap", "sit_idle", "push", "climb", "swim"]
# one-shot clips (jump, punch, kick, sword_slash, hit_react, death, sit_down, interact) are replayed after a short pause

var index := 0
var current: Node3D
var player: AnimationPlayer
var info: Label
var clips: Array = []
var clip_i := 0


func _ready() -> void:
	_build_world()
	_spawn(0)


func _build_world() -> void:
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.2, 0.3, 0.5)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.9, 1.0)
	env.ambient_light_energy = 0.8
	env_node.environment = env
	add_child(env_node)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.shadow_enabled = true
	add_child(sun)

	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	ground.mesh = plane
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.78, 0.82, 0.92)
	ground.material_override = ground_mat
	add_child(ground)

	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 1.6, 5.2)
	cam.look_at(Vector3(0, 1.0, 0))

	var layer := CanvasLayer.new()
	info = Label.new()
	info.position = Vector2(16, 16)
	layer.add_child(info)
	add_child(layer)


func _spawn(i: int) -> void:
	var keep := ""
	if clips.size() > 0:
		keep = clips[clip_i]
	if is_instance_valid(current):
		current.queue_free()
	index = wrapi(i, 0, CHARACTERS.size())
	var scene: PackedScene = load("res://characters/%s.glb" % CHARACTERS[index])
	current = scene.instantiate()
	add_child(current)
	player = current.find_child("AnimationPlayer", true, false) as AnimationPlayer
	clips.clear()
	for c in ORDER:
		if player.has_animation(c):
			clips.append(c)
			if c in LOOPING:
				player.get_animation(c).loop_mode = Animation.LOOP_LINEAR
	player.animation_finished.connect(_on_finished)
	clip_i = max(0, clips.find(keep))
	_play(clip_i)


func _play(i: int) -> void:
	clip_i = wrapi(i, 0, clips.size())
	player.play(clips[clip_i])
	info.text = "%s   [%d/%d  %s]\nUp/Down: clip   1-0: first ten clips   Left/Right: character" % [CHARACTERS[index], clip_i + 1, clips.size(), clips[clip_i]]


func _on_finished(anim_name: StringName) -> void:
	# one-shot clips: wait a moment, then play them again so the demo keeps moving
	if not (String(anim_name) in LOOPING):
		await get_tree().create_timer(0.7).timeout
		if is_instance_valid(player) and player.current_animation == "" and clips[clip_i] == String(anim_name):
			player.play(anim_name)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var k: int = event.keycode
		if k >= KEY_1 and k <= KEY_9:
			_play(k - KEY_1)
		elif k == KEY_0:
			_play(9)
		elif k == KEY_UP:
			_play(clip_i + 1)
		elif k == KEY_DOWN:
			_play(clip_i - 1)
		elif k == KEY_RIGHT:
			_spawn(index + 1)
		elif k == KEY_LEFT:
			_spawn(index - 1)
