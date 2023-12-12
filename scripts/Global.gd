extends Node


var game_on : bool = false



func sus_tween_anim(obj : Object, property : String):
	var tween = create_tween()
	for s in [.8, 1.2, .9, 1.0]:
		tween.tween_property(obj, property, Vector2(1, s), .2)
	tween.play()
