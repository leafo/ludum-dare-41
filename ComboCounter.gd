extends Timer

signal combo_updated(count)

var combo_counter = 0

func increment_combo():
	combo_counter += 1
	emit_signal("combo_updated", combo_counter)
	start()

func end_combo():
	if combo_counter == 0:
		return
		
	stop()
	combo_counter = 0
	emit_signal("combo_updated", combo_counter)

func _on_ComboCounter_timeout():
	combo_counter = 0
	emit_signal("combo_updated", combo_counter)
