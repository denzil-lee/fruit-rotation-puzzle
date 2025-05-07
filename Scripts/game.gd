# In Game.gd, attached to your Game node

extends Node2D

@onready var grid = $GridContainer
@onready var tile_scene := preload("res://Scenes/Tile.tscn")
var time_left: float = 60.0

func _ready():
	randomize()
	# Fill grid with 16 tiles
	for i in 16:
		var tile = tile_scene.instantiate()
		grid.add_child(tile)
	# Connect timer
	#$GameTimer.timeout.connect(_on_timer_timeout)



func _process(delta):
	if time_left > 0:
		time_left -= delta
		$GameTimer/TimerLabel.text = str(ceil(time_left))
		
	else:
		$TimerLabel.text = "0.0"
		$GameTimer.stop()
		game_over(false)

#func _on_timer_timeout():
	## Just in case Timer hits 0 exactly
	#game_over(false)

func game_over(won: bool):
	# Display win/lose — you can pop up a dialog or change scene
	if won:
		print("You win!")
	else:
		print("Time’s up!")
	#get_tree().paused = true

func check_win_condition():
	for tile in $GridContainer.get_children():
		if tile.rotation_degrees != 0:
			return
	# All are at 0°
	game_over(true)


func _on_game_timer_timeout() -> void:
	pass # Replace with function body.
