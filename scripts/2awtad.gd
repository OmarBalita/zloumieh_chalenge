extends Area2D


@export var dmg_scale := 15.0
@export var health := 50.0


func _on_body_entered(body):
	
	if !body.is_in_group("Fly"):
		
		body.take_dmg(dmg_scale)
		
		# not sus animation
		Global.sus_tween_anim(self, "scale")
		
		take_dmg(20.0)

func take_dmg(val : float):
	health -= val
	if health <= 0:
		queue_free()
	
	$ProgressBar.show()
	$ProgressBar.value = health
