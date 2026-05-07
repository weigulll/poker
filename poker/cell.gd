extends Panel

var card = null
 
func can_place():
	return card == null

func place_card(new_card):
	if card != null:
		return false
	card = new_card
	card.position = Vector2(0,0)
	add_child(card)
	return true
