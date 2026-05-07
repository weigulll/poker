extends Area2D

const CARD_SIZE := Vector2(80, 120)
const CARD_COLOR := Color(0.96, 0.96, 0.97)
const CARD_BORDER_COLOR := Color(0.1, 0.1, 0.12)
const CARD_SCALE_HAND := Vector2(2.6, 2.6)
const CARD_SCALE_HAND_HOVER := Vector2(3.0, 3.0)
const CARD_SCALE_HAND_DRAG := Vector2(3.4, 3.4)
const CARD_SCALE_BOARD := Vector2(0.75, 0.75)

func get_board_scale() -> Vector2:
	if board == null:
		return CARD_SCALE_BOARD
	var fit_scale = min(board.CELL_SIZE.x / CARD_SIZE.x, board.CELL_SIZE.y / CARD_SIZE.y)
	return Vector2(fit_scale * 0.9, fit_scale * 0.9)

@export var card_color: Color = CARD_COLOR
@export var rank: String = "2"
@export var suit: String = "♠"

static var dragging_card = null
static var hovered_card = null

var board = null
var hand = null
var grid_position: Vector2i = Vector2i.ZERO
var in_hand := false
var dragging := false
var hovering := false
var drag_offset := Vector2.ZERO
var original_scale := Vector2.ONE
var original_z_index := 0

var rank_label: Label
var suit_label: Label

func _ready():
	if not $CollisionShape2D.shape:
		var shape = RectangleShape2D.new()
		shape.size = CARD_SIZE * 0.9
		$CollisionShape2D.shape = shape
	init_labels()
	update_labels()
	update_collision_shape()
	input_pickable = false
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	queue_redraw()

func update_collision_shape():
	if $CollisionShape2D.shape:
		$CollisionShape2D.shape.size = CARD_SIZE * 0.9 * scale

func init_labels():
	if has_node("RankLabel"):
		rank_label = $RankLabel
	else:
		rank_label = Label.new()
		rank_label.name = "RankLabel"
		rank_label.add_theme_font_size_override("font_size", 18)
		rank_label.add_theme_color_override("font_color", Color(0, 0, 0))
		add_child(rank_label)

	if has_node("SuitLabel"):
		suit_label = $SuitLabel
	else:
		suit_label = Label.new()
		suit_label.name = "SuitLabel"
		suit_label.horizontal_alignment = 1
		suit_label.add_theme_font_size_override("font_size", 32)
		suit_label.add_theme_color_override("font_color", Color(0, 0, 0))
		add_child(suit_label)

func update_labels():
	if rank_label:
		rank_label.text = rank
		rank_label.position = Vector2(-CARD_SIZE.x * 0.42, -CARD_SIZE.y * 0.42)
	if suit_label:
		suit_label.text = suit
		suit_label.position = Vector2(-12, -18)

func set_grid_position(new_grid_position: Vector2i) -> void:
	grid_position = new_grid_position
	position = board.grid_to_world(grid_position)

func _input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and dragging_card == null:
			start_drag()
		elif dragging and dragging_card == self:
			end_drag()
	elif event is InputEventMouseMotion and dragging and dragging_card == self:
		update_drag_position(event.global_position)

func start_drag():
	dragging = true
	dragging_card = self
	drag_offset = global_position - get_global_mouse_position()
	original_scale = CARD_SCALE_HAND
	original_z_index = z_index

	# 拖拽时放大卡牌
	scale = CARD_SCALE_HAND_DRAG
	update_collision_shape()
	z_index = 100

	if in_hand and hand:
		if hovered_card == self:
			hovered_card = null
		hand.remove_card_from_hand(self)

func update_drag_position(mouse_pos: Vector2):
	global_position = mouse_pos + drag_offset

func _on_mouse_entered():
	hovering = true
	if in_hand and not dragging and dragging_card == null:
		if hovered_card != null and hovered_card != self:
			hovered_card.scale = CARD_SCALE_HAND
			hovered_card.update_collision_shape()
		hovered_card = self
		scale = CARD_SCALE_HAND_HOVER
		update_collision_shape()

func _on_mouse_exited():
	hovering = false
	if in_hand and not dragging and dragging_card == null:
		if hovered_card == self:
			hovered_card = null
			scale = CARD_SCALE_HAND
			update_collision_shape()

func end_drag():
	dragging = false
	dragging_card = null
	z_index = original_z_index

	var mouse_pos = get_global_mouse_position()
	var grid_pos = board.world_to_grid(mouse_pos)

	if board.is_in_grid(grid_pos) and board.cells[grid_pos.y][grid_pos.x] == null:
		place_on_board(grid_pos)
	else:
		if in_hand and hand:
			hand.return_card_to_hand(self)
		else:
			scale = original_scale
			set_grid_position(grid_position)

func place_on_board(grid_pos: Vector2i):
	in_hand = false
	rotation = 0
	input_pickable = false
	if hand:
		hand.remove_card_from_hand(self)
	var previous_global = global_position
	board.spawn_card_at(grid_pos, self)
	global_position = previous_global
	var target_global = board.grid_to_world(grid_pos)
	var tween = create_tween()
	tween.tween_property(self, "scale", get_board_scale(), 0.18)
	tween.tween_property(self, "global_position", target_global, 0.18)

func _draw():
	var rect = Rect2(-CARD_SIZE * 0.5, CARD_SIZE)
	draw_rect(rect, card_color, true)
	draw_rect(rect, CARD_BORDER_COLOR, false, 2.0)
	if dragging:
		draw_rect(rect.grow(4), Color(0, 0, 0, 0.2), false, 4.0)
