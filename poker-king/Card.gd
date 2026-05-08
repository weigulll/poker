extends Area2D

const CARD_SIZE := Vector2(112, 160)
const CARD_RADIUS := 10.0
const REST_SCALE := Vector2(1.0, 1.0)
const HOVER_SCALE := Vector2(1.18, 1.18)
const HELD_SCALE := Vector2(1.28, 1.28)

@export var rank := "2"
@export var suit := "♠"

var home_position := Vector2.ZERO
var home_rotation := 0.0
var home_index := 0
var hovered := false
var held := false
var drag_offset := Vector2.ZERO
var rank_label: Label
var suit_label: Label
var corner_label: Label
var tween: Tween

func _ready() -> void:
	input_pickable = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	ensure_labels()
	refresh_labels()
	queue_redraw()

func set_hand_slot(slot_position: Vector2, slot_rotation: float, slot_index: int) -> void:
	home_position = slot_position
	home_rotation = slot_rotation
	home_index = slot_index
	z_index = slot_index
	if not held and not hovered:
		animate_to(home_position, home_rotation, REST_SCALE, 0.18)

func ensure_labels() -> void:
	rank_label = Label.new()
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rank_label.add_theme_font_size_override("font_size", 34)
	rank_label.add_theme_color_override("font_color", Color(0.04, 0.04, 0.05))
	rank_label.size = Vector2(72, 44)
	rank_label.position = Vector2(-36, -57)
	add_child(rank_label)

	suit_label = Label.new()
	suit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	suit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	suit_label.add_theme_font_size_override("font_size", 58)
	suit_label.add_theme_color_override("font_color", Color(0.02, 0.02, 0.025))
	suit_label.size = Vector2(90, 72)
	suit_label.position = Vector2(-45, -6)
	add_child(suit_label)

	corner_label = Label.new()
	corner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	corner_label.add_theme_font_size_override("font_size", 20)
	corner_label.add_theme_color_override("font_color", Color(0.04, 0.04, 0.05))
	corner_label.size = Vector2(42, 50)
	corner_label.position = Vector2(-50, -74)
	add_child(corner_label)

func refresh_labels() -> void:
	if rank_label:
		rank_label.text = rank
	if suit_label:
		suit_label.text = suit
	if corner_label:
		corner_label.text = rank + "\n" + suit

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_hold()
		elif held:
			end_hold()

func _unhandled_input(event: InputEvent) -> void:
	if held and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		end_hold()

func _process(_delta: float) -> void:
	if held:
		global_position = get_global_mouse_position() + drag_offset

func start_hold() -> void:
	held = true
	hovered = false
	drag_offset = global_position - get_global_mouse_position()
	z_index = 300
	animate_to(global_position, 0.0, HELD_SCALE, 0.08)
	queue_redraw()

func end_hold() -> void:
	held = false
	z_index = home_index
	animate_to(home_position, home_rotation, REST_SCALE, 0.22)
	queue_redraw()

func _on_mouse_entered() -> void:
	if held:
		return
	hovered = true
	z_index = 200
	animate_to(home_position + Vector2(0, -96), 0.0, HOVER_SCALE, 0.12)
	queue_redraw()

func _on_mouse_exited() -> void:
	if held:
		return
	hovered = false
	z_index = home_index
	animate_to(home_position, home_rotation, REST_SCALE, 0.16)
	queue_redraw()

func animate_to(target_position: Vector2, target_rotation: float, target_scale: Vector2, duration: float) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_position, duration)
	tween.tween_property(self, "rotation", target_rotation, duration)
	tween.tween_property(self, "scale", target_scale, duration)

func _draw() -> void:
	var rect := Rect2(-CARD_SIZE * 0.5, CARD_SIZE)
	var shadow_offset := Vector2(0, 9 if held else 5)
	draw_rect(Rect2(rect.position + shadow_offset, rect.size), Color(0, 0, 0, 0.2), true)
	draw_rect(rect, Color(0.97, 0.97, 0.94), true)
	draw_rect(rect.grow(-5), Color(1.0, 1.0, 0.985), true)
	draw_rect(rect, Color(0.04, 0.04, 0.05), false, 2.4)
	if hovered or held:
		draw_rect(rect.grow(5), Color(0.95, 0.74, 0.33, 0.75), false, 4.0)
