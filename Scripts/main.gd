extends Control

@onready var grid_container: GridContainer = $CenterContainer/GridContainer
@onready var tile_scene := preload("res://Scenes/Tile.tscn")
@onready var game_timer: Timer = $Timer
@onready var notifier: Label = $Notifier

const ROWS := 4
const COLUMNS := 4

var seconds_left: int = 60
var game_over: bool = false

func _ready() -> void:
	print("-- Game._ready()")  # DEBUG
	# Ensure GridContainer is set to 4 columns
	grid_container.columns = COLUMNS
	print(" GridContainer.columns =", grid_container.columns)
	# Connect the timeout signal using the Godot 4 approach
	if not game_timer.timeout.is_connected(_on_Timer_timeout):
		game_timer.timeout.connect(_on_Timer_timeout)
		print(" Connected Timer.timeout to _on_Timer_timeout")
	else:
		print(" Timer.timeout already connected")
	randomize()
	_spawn_tiles()
	print(" After spawn, child count =", grid_container.get_child_count())
	# Start the timer (set in the Inspector to Wait Time=1, One Shot=Off, Autostart=Off)
	game_timer.start()
	print(" Timer started (wait_time =", game_timer.wait_time, ")")
	notifier.text = str(seconds_left) + "s Left"

func _spawn_tiles() -> void:
	print("-- Spawning tiles")  # DEBUG
	_clear_tiles()
	for row in range(ROWS):
		for col in range(COLUMNS):
			var tile = tile_scene.instantiate()
			tile.grid_row = row
			tile.grid_col = col
			tile.tile_selected.connect(_on_tile_selected)
			grid_container.add_child(tile)
			print("  Instanced tile at (", row, ",", col, ")")
	print(" Done spawning tiles")

func _clear_tiles() -> void:
	print(" Clearing existing tiles (count =", grid_container.get_child_count(), ")")
	for child in grid_container.get_children():
		child.queue_free()
	print(" Cleared tiles, now count =", grid_container.get_child_count())

func _on_tile_selected(tile: Node) -> void:
	print(" Tile selected:", tile.name, "rotation =", tile.rotation_degrees)
	if game_over:
		print("  Ignored: game already over")
		return
	if _check_victory():
		_on_game_victory()

func _check_victory() -> bool:
	for tile in grid_container.get_children():
		if int(tile.rotation_degrees) != 0:
			return false
	return true

func _on_game_victory() -> void:
	game_over = true
	game_timer.stop()
	notifier.text = "You Win!"
	print("** Victory! **")

func _on_Timer_timeout() -> void:
	print(" Timer timeout — seconds_left was", seconds_left)
	seconds_left -= 1
	notifier.text = str(seconds_left) + "s Left"
	if seconds_left == 0:
		game_over = true
		notifier.text = "Time's up! Game over."
		game_timer.stop()
		print("** Time's up — game over **")
	else:
		print(" New seconds_left =", seconds_left)
