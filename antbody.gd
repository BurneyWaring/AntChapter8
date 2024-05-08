extends KinematicBody2D

#This script contains all the ant behaviors

var count = 0
var screenwidth
var screenheight
var pher = 0 #this is a variable that is referenced in the Main.gd scrips as member.pher
var carryingfood = false
var speed 
var smellingpher = false


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() #necessary, otherwise the random values will repeat each time it is run
	rotation_degrees = randi()%360 #start ant going in a random direction
	screenwidth = get_viewport().size.x
	screenheight = get_viewport().size.y
	speed = 140 #speed of the ant
	var a = directiontohome()
	#this adds this ant to the group "ant"
	#which will be very useful for keeping track of all the ant instances in the other scenes
	add_to_group("ant") 

#------------
#This is the main loop function
#the ant is a kinematic body, so use the physics process
func _physics_process(delta):
	count += 1
	if count > 1000:
		count = 0

	isantishome() #check to see if ant is ready to go back into hole

	if carryingfood:
		smellingpher = false

	#Which way should the ant go?
	if carryingfood and count%10 == 0:
		var a = directiontohome()
		if a < 0:
			a += 180
		rotation_degrees = a 
		speed = 180
	elif smellingpher and count%25 ==0:
		var a = smellpher()
		rotation_degrees = a 
	elif count%30 == 0: #change direction only every 30 frames
		#rotation_degrees = randomturn() 
		randomturn()

	#Check if ant can smell pheremones
	smellpher()
	
	#move and collide
	var dist = speed*delta
	var dx = dist * cos(rotation_degrees*0.0174533)
	var dy = dist * sin(rotation_degrees*0.0174533)
	var velocity = Vector2(dx,dy)
	var collision = move_and_collide(velocity) #This is what gives the kinematic body motion and checks for collision also.


	#If ant has some sort of collision, decide what to do
	if collision:
		rotation_degrees = randomturn()
		var a = collision.collider
		if a.is_in_group("ant"): #bumped into an ant
			randomturn()
		elif a.is_in_group("food"): #bumped into the food
			carryingfood = true
			speed = 60
			pher = 1 #signal to main that collided with food
			smellingpher = false
			$foodbite.visible = true
			randomturn()
		else:  #bumped into something else (a red circle)
			randomturn()
			
	#no matter what, need to keep the ants on the screen
	keeponscreen()

#end of the main loop
#-----------------------------------

#keep the ants on the screen
func keeponscreen():
	#Check that the ant is still on screen
	#If not, turn the ant in the opposite direction
	if position.y < 0:
		rotation_degrees = 90
	if position.x < 0:
		rotation_degrees = 0 
	if position.x > screenwidth:
		rotation_degrees = 180
	if position.y > screenheight:
		rotation_degrees = 270

#make a random turn (when scouting or bumping into things)
func randomturn():
	var randdeg = (randi()%90)-50 #a bit of a bias to turning right
	rotation_degrees += randdeg
	if rotation_degrees < 0:
		rotation_degrees = rotation_degrees + 360 
	return rotation_degrees

#which way is home (the anthill)?
func directiontohome ():
	pass
	var a = rad2deg( (position-Global.anthill_location).angle())  + 180
	if a <0:
		a += 180
	pass
	return a

#Can the ant stay home?
func isantishome():
#Is the ant carrying food?
#Is the ant very close to home?
# If so, ant disappears into the anthill.
	if carryingfood:
		var a = position-Global.anthill_location
		var dist = sqrt(a.x*a.x+a.y*a.y) #how far from home?
		if dist<10: #less than 10 pixels away
			queue_free() #the end of the ant in the simulation

#Ant will try to smell pher
func smellpher():
	#This function checks distance to pher
	# and the angle to pher
	#If it can smell it, it sets the smellingpher flag to true.
	#The function always determines the direction,
	#but the _physics process doesn't care unless smellingpher is true
	
	#how much pher is there?
	var num_members = len(get_tree().get_nodes_in_group("pher"))
	var mindist = 999999

#how close is the ant to the closest pher?
	for member in get_tree().get_nodes_in_group("pher"):
		var a = position-member.position
		var dist = sqrt(a.x*a.x+a.y*a.y)
		if dist<mindist:
			mindist = dist

#if at least one pheremone blob is within 250 pixels, the ant will smell it and turn toward the smell
	if mindist <= 250:
		smellingpher = true
	else:
		smellingpher = false

#in what direction is the pher blob?
	var sum_angle = 0
	for member in get_tree().get_nodes_in_group("pher"):
		#calculates the ange to the pher
		var a = rad2deg( (position-member.position).angle())  + 180
		sum_angle += a
		pass
	var avgangle = 0
	if num_members>0:
		avgangle = sum_angle/num_members
	return avgangle #the average angle to the pher blobs
#when the ant is near a big blob, it will change direction as it approaches
# and may get confused or stuck in the blob.
#This seems realistic.


