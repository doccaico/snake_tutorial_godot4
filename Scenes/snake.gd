extends Node2D

@onready var tile = $Tile
@onready var score = $Score

const SNAKE = Vector2i(1, 0)
const FOOD = Vector2i(0, 1)
const WALL = Vector2i(1, 1)

var rng: RandomNumberGenerator
var segments: Array[Vector2i]
var dir: Vector2i
var dirqueue: Array[Vector2i]
var speed: float
var alive: bool
var duration: float

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	segments = [
		Vector2i(7, 24),
		Vector2i(8, 24),
		Vector2i(9, 24),
		Vector2i(10, 24),
	]
	dir = Vector2i(1, 0)
	dirqueue = []
	speed = 7.0
	alive = true
	duration = 0.0
	
	for s in segments:
		tile.set_cell(0, s, 0, SNAKE)
	
	put_food()

func _process(delta: float) -> void:
	
	duration += delta
	if duration >= 1.0 / speed and alive:
		if len(dirqueue) >= 1:
			var newdir = dirqueue[0]
			dirqueue.remove_at(0)
			var opposite = newdir.x == -dir.x or newdir.y == -dir.y
			if not opposite:
				dir = newdir
		
		var head = segments[len(segments) - 1]
		var newhead = Vector2i(head.x + dir.x, head.y + dir.y)
		
		segments.append(newhead)
		
		var coords = tile.get_cell_atlas_coords(0, newhead)
		if coords == SNAKE or coords == WALL:
			alive = false
		elif coords == FOOD:
			score.increment()
			speed += 1
			put_food()
		else:
			tile.erase_cell(0, segments[0])
			segments.remove_at(0)
		
		for s in segments:
			tile.set_cell(0, s, 0, SNAKE)
		
		duration = 0.0
	
	if not alive:
		# Snake is dead
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		dirqueue.append(Vector2i(0, -1))
	elif event.is_action_pressed("ui_down"):
		dirqueue.append(Vector2i(0, 1))
	elif event.is_action_pressed("ui_left"):
		dirqueue.append(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_right"):
		dirqueue.append(Vector2i(1, 0))

func put_food() -> void:
	var pos: Vector2i
	while true:
		pos = Vector2i(rng.randi_range(1, 46), rng.randi_range(1, 46))
		var coords = tile.get_cell_atlas_coords(0, pos)
		if coords != SNAKE and coords != WALL:
			break
	tile.set_cell(0, pos, 0, FOOD)
