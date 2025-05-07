extends TextureRect

@export var grid_row: int = 0
@export var grid_col: int = 0
@export var snap_degrees: int = 90        # rotation step
@export var tween_duration: float = 0.2   # seconds
@export var disable_chance: float = 0.25  # 25% chance to lock for 2s
@export var sprite_typ: Array[Texture] = []

signal tile_selected(tile)

func _ready() -> void:
	randomize()
	await get_tree().process_frame
	if sprite_typ.size() >= 0:
		texture = sprite_typ[ randi() % sprite_typ.size()]
	# pick a random multiple of snap_degrees
	var steps = 360 / snap_degrees
	rotation_degrees = int(randi() % steps) * snap_degrees
	mouse_filter = MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and mouse_filter == MOUSE_FILTER_STOP:
		_animate_rotation()

func _animate_rotation() -> void:
	var current = rotation_degrees
	var target = fmod(current + snap_degrees, 360)
	var tw = create_tween()
	tw.tween_property(self, "rotation_degrees", target, tween_duration) \
	  .set_trans(Tween.TRANS_CUBIC) \
	  .set_ease(Tween.EASE_OUT)
	tw.tween_callback(Callable(self, "_on_tween_complete"))

func _on_tween_complete() -> void:
	# snap to exact multiple
	rotation_degrees = int((rotation_degrees + snap_degrees * 0.5) / snap_degrees) * snap_degrees % 360
	emit_signal("tile_selected", self)
	# roll for a temporary lock
	if randf() < disable_chance:
		_lock_for_seconds(2.0)

func _lock_for_seconds(duration: float) -> void:
	# disable further clicks
	mouse_filter = MOUSE_FILTER_IGNORE
	# create a one-shot timer
	var t = Timer.new()
	t.wait_time = duration
	t.one_shot = true
	add_child(t)
	t.start()
	# when it fires, re-enable input and free itself
	t.timeout.connect(func():
		mouse_filter = MOUSE_FILTER_STOP
		t.queue_free()
	)
