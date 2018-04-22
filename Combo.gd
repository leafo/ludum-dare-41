extends Label

func _ready():
	text = ""

func _on_ComboCounter_combo_updated(count):
	if count > 0:
		text = "Combo %02d" % count
	else:
		text = ""
