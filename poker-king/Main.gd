extends Node2D

const CARD_SCENE := preload("res://Card.tscn")
const RANKS := ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
const TABLE_GREEN := Color(0.08, 0.34, 0.17)
const FELT_GREEN := Color(0.1, 0.45, 0.22)
const GOLD := Color(0.92, 0.72, 0.34)

var cards: Array = []
var hand_anchor := Vector2.ZERO

func _ready() -> void:
	for rank in RANKS:
		var card = CARD_SCENE.instantiate()
		card.rank = rank
		card.suit = "♠"
		add_child(card)
		cards.append(card)
	arrange_hand()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		arrange_hand()
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		arrange_hand()

func arrange_hand() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var count: int = cards.size()
	if count == 0:
		return

	hand_anchor = Vector2(viewport_size.x * 0.5, viewport_size.y + 58.0)
	var fan_width: float = min(760.0, viewport_size.x * 0.78)
	var spacing: float = fan_width / float(max(1, count - 1))
	var start_x: float = hand_anchor.x - fan_width * 0.5
	var center_index: float = float(count - 1) * 0.5

	for i in range(count):
		var card = cards[i]
		var normalized: float = (float(i) - center_index) / max(1.0, center_index)
		var x: float = start_x + spacing * float(i)
		var y: float = viewport_size.y - 132.0 + abs(normalized) * 26.0
		var angle: float = deg_to_rad(normalized * 18.0)
		card.set_hand_slot(Vector2(x, y), angle, i)

func _draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), TABLE_GREEN, true)
	for y in range(0, int(viewport_size.y), 48):
		draw_rect(Rect2(Vector2(0, y), Vector2(viewport_size.x, 24)), Color(0.16, 0.58, 0.25, 0.11), true)

	var arena := Rect2(Vector2(70, 54), viewport_size - Vector2(140, 190))
	draw_rect(arena.grow(18), Color(0.02, 0.12, 0.07, 0.42), true)
	draw_rect(arena, FELT_GREEN, true)
	draw_rect(arena, GOLD, false, 3.0)

	var play_zone := Rect2(arena.position + Vector2(36, 34), arena.size - Vector2(72, 68))
	draw_rect(play_zone, Color(0.03, 0.16, 0.1, 0.22), true)
	draw_rect(play_zone, Color(0.55, 0.8, 0.54, 0.18), false, 2.0)
