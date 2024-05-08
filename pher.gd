extends Sprite

var clr = 1.0

func _ready():
	add_to_group("pher") 

func _process(delta):
	clr -= 1.0/1000.0  #will take 1000 frames to fade completely
	self_modulate = Color (1.0-clr,1.0-clr,1.0,clr)
	if clr < 0.0:		
		queue_free()  
