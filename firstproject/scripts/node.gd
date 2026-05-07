extends Node

var score = 0

@onready var label = $label

func add_point():
	score += 1
	label.text = "you got "+str(score)+" coins nice job"
