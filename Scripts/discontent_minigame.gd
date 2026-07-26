extends Minigame

@export var sentences = 1
var sentence = ""
var comp_sentence = ""
var written = ""
var pos = 0
var space = 0
var last_index = 0

var sentence_list = [
	"There have been reports of adib staring", 
	"Hello everyone nice to see you", 
	"Do not panic everything is under control", 
	"I am here for you if you need anything", 
	"We will get through this together", 
	"I understand your concerns but remain calm", 
	"Remember the mission we will get through this",
	"Sometimes sacrifices must be made", 
	"Do not worry we are still in control", 
	"Please be calm and do not yell",
	"I promise everything will be ok"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%input.call_deferred("grab_focus")
	_generate_sentence()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_text_changed(new_text: String) -> void:
	written = %input.text.to_lower().replace(' ', '')
	new_text = new_text.replace(' ', '')
	printt(written, comp_sentence)
	for i in range(pos, len(new_text)):
		if written[i] == comp_sentence[i]:
			if sentence[i + space] == " ":
				print("space detected")
				space += 1
			var new_sentence = sentence.insert(space + i + 1, "[/color]") 
			new_sentence = new_sentence.insert(0, "[color=green]") 
			%words.text = new_sentence
			print(new_sentence)
			pos += 1
		else:
			# wrong lol
			print("lose")
			finish()
			break
		
	if pos >= len(comp_sentence):
		if sentences <= 0:
			print("win")
			finish()
		else:
			_generate_sentence()


func _generate_sentence():
	sentences -= 1
	pos = 0
	space = 0
	%input.text = ""
	var index = randi() % len(sentence_list)
	if index == last_index:
		index = (index + 1) % len(sentence_list)
	else:
		last_index = index
	sentence = sentence_list[index]
	comp_sentence = sentence.to_lower().replace(" ", "")
	%words.text = sentence
