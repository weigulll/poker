extends Node2D

const GRID_ROWS := 10
const GRID_COLS := 10
const CELL_SIZE := Vector2(76, 76)
const GRID_COLOR := Color(0.7, 0.7, 0.7, 1.0)
const HIGHLIGHT_COLOR := Color(1, 1, 1, 0.15)
const CARD_SCENE := preload("res://Card.tscn")

var cells: Array = []
var hover_cell := Vector2i(-1, -1)
var grid_origin := Vector2.ZERO

func _ready():
	init_grid()
	_recalculate_origin()
	position = Vector2.ZERO
	set_process(true)
	queue_redraw()

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_recalculate_origin()
		queue_redraw()

func _recalculate_origin():
	var screen_size = get_viewport_rect().size
	grid_origin = Vector2((screen_size.x - GRID_COLS * CELL_SIZE.x) / 2, 10)

func init_grid():
	cells.resize(GRID_ROWS)
	for row in range(GRID_ROWS):
		cells[row] = []
		for col in range(GRID_COLS):
			cells[row].append(null)

func _process(delta):
	var new_hover = world_to_grid(get_global_mouse_position())
	if new_hover != hover_cell:
		hover_cell = new_hover
		queue_redraw()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var grid_pos = world_to_grid(get_global_mouse_position())
		if is_in_grid(grid_pos) and cells[grid_pos.y][grid_pos.x] == null:
			spawn_card(grid_pos)
			queue_redraw()

func spawn_card(grid_pos: Vector2i) -> void:
	var card = CARD_SCENE.instantiate()
	card.board = self
	card.scale = card.get_board_scale()
	card.update_collision_shape()
	card.grid_position = grid_pos
	card.position = grid_to_world(grid_pos)
	$Cards.add_child(card)
	cells[grid_pos.y][grid_pos.x] = card

func spawn_card_at(grid_pos: Vector2i, card) -> void:
	card.board = self
	card.scale = card.get_board_scale()
	card.update_collision_shape()
	card.grid_position = grid_pos
	card.position = grid_to_world(grid_pos)
	$Cards.add_child(card)
	cells[grid_pos.y][grid_pos.x] = card

func move_card_to(card, target_grid_pos: Vector2i) -> void:
	if not is_in_grid(target_grid_pos):
		card.set_grid_position(card.grid_position)
		return
	if cells[target_grid_pos.y][target_grid_pos.x] != null and cells[target_grid_pos.y][target_grid_pos.x] != card:
		card.set_grid_position(card.grid_position)
		return
	var origin = card.grid_position
	if target_grid_pos == origin:
		card.set_grid_position(origin)
		return
	cells[origin.y][origin.x] = null
	cells[target_grid_pos.y][target_grid_pos.x] = card
	card.grid_position = target_grid_pos
	card.position = grid_to_world(target_grid_pos)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local = to_local(world_pos) - grid_origin
	return Vector2i(floor(local.x / CELL_SIZE.x), floor(local.y / CELL_SIZE.y))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return grid_origin + Vector2(grid_pos) * CELL_SIZE + CELL_SIZE * 0.5

func is_in_grid(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_COLS and grid_pos.y >= 0 and grid_pos.y < GRID_ROWS

func _draw():
	var screen_size = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, screen_size), Color(0.16, 0.55, 0.2), true)
	for i in range(0, int(screen_size.y), 40):
		draw_rect(Rect2(Vector2(0, i), Vector2(screen_size.x, 20)), Color(0.14, 0.6, 0.22, 0.2), true)

	var table_rect = Rect2(grid_origin - Vector2(30, 30), Vector2(GRID_COLS * CELL_SIZE.x + 60, GRID_ROWS * CELL_SIZE.y + 60))
	draw_rect(table_rect, Color(0.12, 0.35, 0.1), true)
	draw_rect(table_rect.grow(-8), Color(0.2, 0.4, 0.18), true)
	draw_rect(table_rect.grow(-16), Color(0.16, 0.4, 0.14), true)

	var grid_rect = Rect2(grid_origin, Vector2(GRID_COLS * CELL_SIZE.x, GRID_ROWS * CELL_SIZE.y))
	draw_rect(grid_rect, Color(0.2, 0.35, 0.12), true)
	for y in range(GRID_ROWS + 1):
		draw_line(grid_origin + Vector2(0, y * CELL_SIZE.y), grid_origin + Vector2(GRID_COLS * CELL_SIZE.x, y * CELL_SIZE.y), GRID_COLOR, 2)
	for x in range(GRID_COLS + 1):
		draw_line(grid_origin + Vector2(x * CELL_SIZE.x, 0), grid_origin + Vector2(x * CELL_SIZE.x, GRID_ROWS * CELL_SIZE.y), GRID_COLOR, 2)
	if is_in_grid(hover_cell):
		draw_rect(Rect2(grid_to_world(hover_cell) - CELL_SIZE * 0.5, CELL_SIZE), HIGHLIGHT_COLOR, true)
