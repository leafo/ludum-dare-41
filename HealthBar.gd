extends TextureProgress

func _on_Player_health_update(health):
	$Tween.interpolate_property(self, "value", value, health, 0.3, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$Tween.start()
	