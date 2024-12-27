extends Node3D

@export var textBlocks: Array[String]

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer;
@onready var textAnimPlayer: AnimationPlayer = $Control/TextAnimationPlayer
@onready var textLabel: RichTextLabel = $Control/RichTextLabel

var currentTextBlock: int = 0
var isFading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animationPlayer.play("WolfArmature|IdleTalk")
	playNextTextBlock()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("GoWild"):
		if(currentTextBlock < 4):
			playNextTextBlock()
		else:
			isFading = true
			textAnimPlayer.play("FadeOut")
	
func playNextTextBlock() -> void:
	#textLabel.add_text(textBlocks[currentTextBlock])
	textLabel.text = textBlocks[currentTextBlock]
	currentTextBlock += 1
	textLabel.visible_ratio = 0
	textAnimPlayer.play("Text|BlessYouChild")
	
func StartPlaying() -> void:
	get_tree().change_scene_to_file("res://Levels/BasicLevel.tscn")
	
	
