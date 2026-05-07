extends Control

@onready var grid = $GridContainer
var cell_scene = preload("res://assets/Cards/cardBack_blue1.png")

func _ready():
	for i in range(100):
		var cell = cell_scene.instantiate()
		grid.add_child(cell)
