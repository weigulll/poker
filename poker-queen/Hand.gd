extends Node2D

const CARD_SCENE := preload("res://Card.tscn")
const HAND_GAP := 20
const HAND_RADIUS := 320
const CARD_RANKS := ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]

var hand_cards: Array = []

func _ready():
    for rank in CARD_RANKS:
        add_card_to_hand(rank)

func add_card_to_hand(rank: String):
    var card = CARD_SCENE.instantiate()
    card.board = get_parent().get_node("Board")
    card.hand = self
    card.in_hand = true
    card.rank = rank
    card.suit = "♠"
    card.scale = card.CARD_SCALE_HAND
    card.update_collision_shape()
    card.input_pickable = true
    $Cards.add_child(card)
    hand_cards.append(card)
    arrange_hand()

func arrange_hand():
    var board = get_parent().get_node("Board")
    if board == null:
        return

    var card_count = hand_cards.size()
    if card_count == 0:
        return

    var center_x = board.grid_origin.x + board.GRID_COLS * board.CELL_SIZE.x * 0.5
    var base_y = board.grid_origin.y + board.GRID_ROWS * board.CELL_SIZE.y + HAND_GAP
    var angle_step = deg_to_rad(6)
    var start_angle = -angle_step * (card_count - 1) / 2

    for i in range(card_count):
        var card = hand_cards[i]
        var angle = start_angle + angle_step * i
        var x = center_x + HAND_RADIUS * sin(angle)
        var y = base_y + HAND_RADIUS * (1 - cos(angle))
        card.position = Vector2(x, y)
        card.rotation = angle * 0.5
        card.z_index = i

func _notification(what):
    if what == NOTIFICATION_WM_SIZE_CHANGED:
        arrange_hand()

func remove_card_from_hand(card):
    if card in hand_cards:
        hand_cards.erase(card)
        arrange_hand()

func return_card_to_hand(card):
    card.in_hand = true
    card.scale = card.CARD_SCALE_HAND
    card.update_collision_shape()
    card.input_pickable = true
    card.rotation = 0
    hand_cards.append(card)
    arrange_hand()

func is_top_card(card) -> bool:
    return hand_cards.size() > 0 and hand_cards[hand_cards.size() - 1] == card
