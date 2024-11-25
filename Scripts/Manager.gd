extends Node

@export var text_editor : TextEdit
@export var inputs_field : TextEdit
@export var output_field : RichTextLabel

var all_lines : Array

var all_values : Dictionary = {"Y":0}

var line_counter : int = 0

var had_error : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setup_all_values():
	all_values["Y"] = 0
	var _c = 0
	var _tmp = inputs_field.text.split(",")
	for t in _tmp:
		all_values["X"+str(_c)] = int(t)
		_c += 1
	print(all_values)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_run_btn_pressed():
	line_counter=0
	setup_all_values()
	text_editor.text = text_editor.text.to_upper()
	all_lines = text_editor.text.split("\n")
	run_the_code()
	print_output()
	return all_values["Y"]

func run_the_code():
	# checks if we need to skip or end the program
	if line_counter >= len(all_lines) or line_counter < 0:
		if not had_error:
			print_output()
		return
	elif all_lines[line_counter] == "" or all_lines[line_counter] == " ":
		line_counter += 1
		run_the_code()
		return
	# detect comments
	if all_lines[line_counter][0] == "/":
		line_counter += 1
		run_the_code()
		return
	else :
		all_lines[line_counter] = all_lines[line_counter].split("//")[0]
		while  all_lines[line_counter].ends_with(" ") or all_lines[line_counter].ends_with("\t"):
			all_lines[line_counter][-1] = ""
	var current_line : String = all_lines[line_counter]
	var assign_left : String
	var assign_right : String
	
	# if it has a label, we'll ignore the label
	if current_line[0] == '[' :
		while current_line[0] != ']':
			current_line[0] = ""
		current_line[0] = ""
		while current_line[0] == " ":
			current_line[0] = ""
			
	# now we have a runnable code
	# if the instruction is an IF statement
	if current_line.contains("IF"):
		var if_parts = current_line.split(" ")
		if not (if_parts[1].split("!=")[0] in all_values.keys()):
			all_values[if_parts[1].split("!=")[0]] = 0
		if all_values[if_parts[1].split("!=")[0]] != 0:	# run goto
			assign_right = if_parts[3]
			print(assign_right)
			# checking GOTO E
			if assign_right.contains("E"):
				line_counter = len(all_lines) + 1
				print_output()
				return
			
			var label_found : bool = false
			for c in range(len(all_lines)):
				if all_lines[c].contains(assign_right) and (not (all_lines[c].contains("GOTO " + assign_right))):
					line_counter = c
					label_found = true
					break
			if not label_found:
				print_error("The label " + assign_right + " at the line " + str(line_counter+1) + " isn't found.")
				line_counter = len(all_lines) + 1
				return
			run_the_code()
		# if statement is false
		else :
			line_counter += 1
			run_the_code()
		
	# if the instruction is INCR or DECR or assign
	elif current_line.contains("<-"):
		for c in range(len(current_line)):
			if c >= len(current_line):
				break
			if current_line[c]==" ":
				current_line[c] = ""
		assign_left = current_line.split("<-")[0]
		assign_right = current_line.split("<-")[1]
		## check the op
		# INCR instruction
		if assign_right.contains("+1") or assign_right.contains("+ 1"):
			if assign_right.contains(assign_left) == false:
				print_error("You used the INCR instruction in a wrong way at the line " + str(line_counter+1))
				line_counter = len(all_lines) + 1
				return
			else :
				if not (assign_left in all_values.keys()):
					all_values[assign_left] = 0
				all_values[assign_left] += 1
		# DECR instruction
		elif assign_right.contains("-1") or assign_right.contains("- 1"):
			if assign_right.contains(assign_left) == false:
				print_error("You used the INCR instruction in a wrong way at the line " + str(line_counter+1))
				line_counter = len(all_lines) + 1
				return
			else :
				if not (assign_left in all_values.keys()):
					all_values[assign_left] = 0
				all_values[assign_left] -= 1
				if all_values[assign_left] < 0:
					all_values[assign_left] = 0
		else :	# assign
			if assign_right in all_values.keys():
				all_values[assign_left] = all_values[assign_right]
			else :
				all_values[assign_right] = 0
				all_values[assign_left] = all_values[assign_right]
		line_counter += 1
		run_the_code()
	elif current_line.begins_with("GOTO"):
		assign_right = current_line.split(" ")[1]
		if assign_right.contains("E"):
			line_counter = len(all_lines) + 1
			return
		
		var label_found : bool = false
		for c in range(len(all_lines)):
			if all_lines[c].contains(assign_right) and (not (all_lines[c].contains("GOTO " + assign_right))):
				line_counter = c
				print(all_lines[line_counter])
				label_found = true
				break
		if not label_found:
			print_error("The label " + assign_right + " at the line " + str(line_counter+1) + " isn't found.")
			line_counter = len(all_lines) + 1
			return
		run_the_code()
	# errors
	else :
		print_error("Non defined instruction at line " + str(line_counter + 1))

func print_output():
	output_field.text = str(all_values["Y"])
	
func print_error(_error):
	had_error = true
	line_counter = len(all_lines) + 1
	output_field.text = "There is an error : " + _error
	all_values["Y"] = "There is an error : " + _error
