extends Label

func _ready() -> void:
	Globals.score = 0


func increment() -> void:
	Globals.score += 1
	text = "Score: %s" % Globals.score
