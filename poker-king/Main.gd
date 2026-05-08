extends Node2D

const CARD_SCENE := preload("res://Card.tscn")
const RANKS := ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const TABLE_GREEN := Color(0.08, 0.34, 0.17)
const FELT_GREEN := Color(0.1, 0.45, 0.22)
const GOLD := Color(0.92, 0.72, 0.34)
const GRID_ROWS := 10
const GRID_COLS := 10
const CELL_SIZE := Vector2(54, 54)

var cards: Array = []
var hand_cards: Array = []
var board_cells: Array = []
var hand_anchor := Vector2.ZERO
var grid_origin := Vector2.ZERO
var hovered_card = null
var selected_card = null

func _ready() -> void:
	init_board()
	for rank in RANKS:
		var card = CARD_SCENE.instantiate()
		card.rank = rank
		card.suit = "♠"
		card.controller = self
		add_child(card)
		cards.append(card)
		hand_cards.append(card)
	arrange_hand()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		arrange_hand()
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		reset_cards_to_hand()

func init_board() -> void:
	board_cells.resize(GRID_ROWS)
	for row in range(GRID_ROWS):
		board_cells[row] = []
		for _col in range(GRID_COLS):
			board_cells[row].append(null)

func arrange_hand() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	update_grid_origin(viewport_size)
	var count: int = hand_cards.size()
	if count == 0:
		return

	hand_anchor = Vector2(viewport_size.x * 0.5, viewport_size.y + 58.0)
	var fan_width: float = min(760.0, viewport_size.x * 0.78)
	var spacing: float = fan_width / float(max(1, count - 1))
	var start_x: float = hand_anchor.x - fan_width * 0.5
	var center_index: float = float(count - 1) * 0.5

	for i in range(count):
		var card = hand_cards[i]
		var normalized: float = (float(i) - center_index) / max(1.0, center_index)
		var x: float = start_x + spacing * float(i)
		var y: float = viewport_size.y - 132.0 + abs(normalized) * 26.0
		var angle: float = deg_to_rad(normalized * 18.0)
		card.set_hand_slot(Vector2(x, y), angle, i)

func update_grid_origin(viewport_size: Vector2) -> void:
	var grid_size := Vector2(GRID_COLS, GRID_ROWS) * CELL_SIZE
	grid_origin = Vector2((viewport_size.x - grid_size.x) * 0.5, 72.0)

func request_hover(card) -> bool:
	if selected_card != null:
		return false
	if hovered_card != null and hovered_card != card:
		hovered_card.cancel_hover()
	hovered_card = card
	return true

func clear_hover(card) -> void:
	if hovered_card == card:
		hovered_card = null

func request_selection(card) -> bool:
	if selected_card != null and selected_card != card:
		return false
	if hovered_card != null and hovered_card != card:
		hovered_card.cancel_hover()
	hovered_card = null
	selected_card = card
	return true

func release_selection(card) -> void:
	if selected_card != card:
		return
	selected_card = null
	var grid_pos := world_to_grid(card.global_position)
	if is_grid_available(grid_pos, card):
		place_card_on_board(card, grid_pos)
	else:
		card.return_home()

func place_card_on_board(card, grid_pos: Vector2i) -> void:
	if card.board_position != Vector2i(-1, -1):
		board_cells[card.board_position.y][card.board_position.x] = null
	if card in hand_cards:
		hand_cards.erase(card)
		arrange_hand()
	board_cells[grid_pos.y][grid_pos.x] = card
	card.set_board_slot(grid_to_world(grid_pos), grid_pos, 120 + grid_pos.y * GRID_COLS + grid_pos.x)

func reset_cards_to_hand() -> void:
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			board_cells[row][col] = null
	hand_cards.clear()
	hovered_card = null
	selected_card = null
	for i in range(cards.size()):
		var card = cards[i]
		card.board_position = Vector2i(-1, -1)
		hand_cards.append(card)
	arrange_hand()
	queue_redraw()

func world_to_grid(world_position: Vector2) -> Vector2i:
	var local := world_position - grid_origin
	return Vector2i(floor(local.x / CELL_SIZE.x), floor(local.y / CELL_SIZE.y))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return grid_origin + Vector2(grid_pos) * CELL_SIZE + CELL_SIZE * 0.5

func is_in_grid(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_COLS and grid_pos.y >= 0 and grid_pos.y < GRID_ROWS

func is_grid_available(grid_pos: Vector2i, card) -> bool:
	if not is_in_grid(grid_pos):
		return false
	var occupying_card = board_cells[grid_pos.y][grid_pos.x]
	return occupying_card == null or occupying_card == card

func _draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	update_grid_origin(viewport_size)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), TABLE_GREEN, true)
	for y in range(0, int(viewport_size.y), 48):
		draw_rect(Rect2(Vector2(0, y), Vector2(viewport_size.x, 24)), Color(0.16, 0.58, 0.25, 0.11), true)

	var grid_size := Vector2(GRID_COLS, GRID_ROWS) * CELL_SIZE
	var arena := Rect2(grid_origin - Vector2(38, 28), grid_size + Vector2(76, 56))
	draw_rect(arena.grow(18), Color(0.02, 0.12, 0.07, 0.42), true)
	draw_rect(arena, FELT_GREEN, true)
	draw_rect(arena, GOLD, false, 3.0)

	var board_rect := Rect2(grid_origin, grid_size)
	draw_rect(board_rect, Color(0.03, 0.16, 0.1, 0.22), true)
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var cell_rect := Rect2(grid_origin + Vector2(col, row) * CELL_SIZE, CELL_SIZE)
			draw_rect(cell_rect.grow(-2), Color(0.12, 0.36, 0.18, 0.58), true)
			draw_rect(cell_rect, Color(0.55, 0.8, 0.54, 0.36), false, 1.5)
