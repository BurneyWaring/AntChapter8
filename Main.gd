#From the Book:
#Create Compelling Science and Engineering Simulations Using the Godot Engine, Copyright 2024 Burney Waring, ThankGod Egbe, Lateef Kareem 
#Chapter 8

extends Node2D

#This simulation is to show some behavior that emerges from many actors acting on their own  simple rules.
#In this case an ant colony will search for food until all the ants find the food.

#Ants scout for food.
#If ants find food (by colliding into it) they release pheremones.
#If ants find food they carry food back to nest (ants remember the direction to the nest).
#The pheremone attracts other ants within a distance (250 pixels).
#Those attracted ants bump into the food and also drop pheremone before going to the nest.

#There are red circles that are barriers.
#The food is a green square.
#The red and green squares are static bodies,
#The ants are kinematic bodies.
#The ants search in a random pattern controled by code.
#The ants collide with the squares. Godot trys to handle the collision by some random motion.

#This project makes use of groups. See the Node tab (next to the Inspector tab).
#The ants are in the group 'ant'. 
#Pheremone drops are in the gropu 'pher'.
#Food is in it's own group, 'food'.
#The project shows how to call all the members of a group and how to check if an object is a member of a  group.

#There are many things that can be studied with this sort of simulation.
#Notice behaviors based on the set up of the circles and the food.
#Notice how if many ants are close together when the first finds the food, they are finished quickly.
#Notice how the last ant can take a long time to get its food.
#What is the difference if there are a lot of obstructions?
#What is the difference if the obstructions are spaced evenly?
#What is the optimum number of ants?

var num_ants = 0#-1 #the first ant created will be zero
var pher_instance
var pher_scene
var count = 0
var foundfood = false
var timestart
var number_of_circles = 40
var lasttime = 0.000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	randomize() #makes all the random things actually random
	pher_scene = load("res://pher.tscn")
	$anthill.position = Global.anthill_location
	$food.position = Vector2(randi()%900+50, randi()%500+50)
	make_circles()
	timestart = OS.get_ticks_msec()#get_unix_time()
	$food.add_to_group("food")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	count += 1
	#This controls how fast the next ant comes out
	if count%50 == 0 and num_ants<Global.max_ants:
		make_one_ant()

#count ants and time for data
	var timenow = OS.get_ticks_msec()
	var totaltime = (timenow - timestart)/1000.0
	# Count ants
	if count%5 == 0:
		var t = totaltime 
		var v = len(get_tree().get_nodes_in_group("ant"))
		Global.datax.append(t)
		Global.datay.append(v)

#stop the time after the ants have started getting food and there are no ants left
	if !(len(get_tree().get_nodes_in_group("ant")) == 0 and foundfood) and len(Global.datay)>0:
		$elapsedtime.text = str(stepify(totaltime,0.001))+ " seconds  " + str(Global.datay[-1])+" ants"
		lasttime = totaltime
	elif len(get_tree().get_nodes_in_group("ant")) == 0 and foundfood:
		  $elapsedtime.text = str(stepify(lasttime,0.001)) + " seconds  " + "0 ants"

	#check for any ants that need to leave pheremone (pher=1) and make a blob
	for member in get_tree().get_nodes_in_group("ant"):
		if member.pher == 1: #ant collided with food
			foundfood = true
			#add some pher on the ground
			pher_instance = pher_scene.instance()
			add_child(pher_instance)
			pher_instance.position = member.position #Vector2(50,50)
			member.pher = 3 #ant no longer leaves pher
	print(len(get_tree().get_nodes_in_group("ant")))

#creates an ant at the anthill
func make_one_ant():
	var ant_scene = load("res://antbody.tscn")
	var ant_instance = ant_scene.instance()
	add_child(ant_instance)
	ant_instance.position = Global.anthill_location
	num_ants += 1 #count all the ants ever made

#make all the obstruction circles
#it might be interesting to space them evenly or in other ways
func make_circles():
	var circle_scene = load("res://circle.tscn")
	for i in range(number_of_circles):
		var circle_instance = circle_scene.instance()
		add_child(circle_instance)
		circle_instance.position = Vector2(randi()%900+50, randi()%500+50)

#A very easy way to reset the whole scene
func _on_resetbutton_pressed():
	#reset data
	Global.datax = [0.001]  
	Global.datay = [0.001]
	get_tree().reload_current_scene() #reset the scene

#Change scene to the graph (abandons this Main scene)
func _on_graph_pressed():
	#this is the static graph button
	Global.staticgraphflag = true #set so that graph will add the data points
	get_tree().change_scene("res://Graph.tscn")

#Hit Esc key to exit at any time
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
