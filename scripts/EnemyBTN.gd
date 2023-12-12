extends Button

signal enemy_btn_pressed(type : String)

# تأكد من أن الإسم الذي تختاره موجود في الenemy_type في عقدة الWorld 
# إن لم يكن الإسم موجودا فلن يتم وضع أي عدو عند الضغط على زر الماوس الأيمن يا هبيبي 
@export var enemy_name : String
@export var black_enemy_name : String


func _ready():
	connect("pressed", send_btn_signal)


# عند الضغط على الزر سيتم إرسال الenemy type إلى الworld 

func send_btn_signal():
	emit_signal("enemy_btn_pressed", enemy_name if %EnemyType.text == "أبيض" else black_enemy_name)
	
	for btn in get_parent().get_children():
		if btn is BaseButton:
			btn.button_pressed = false
	button_pressed = true
