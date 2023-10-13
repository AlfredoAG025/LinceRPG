extends Control

@export var player_mons_scene: PackedScene
@export var enemy_mons_scene: PackedScene

@export var player_mons: Monster
@export var enemy_mons: Monster

@onready var player_mons_pos = $PlayerMonsPos
@onready var enemy_mons_pos = $EnemyMosPos

@onready var p_name = $Player_Info/Label
@onready var e_name = $Enemy_Info/Label
@onready var p_bar = $Player_Info/ProgressBar
@onready var e_bar = $Enemy_Info/ProgressBar

@onready var message = $TextBox/Label

@onready var animation_player = $AnimationPlayer

@onready var fight_btn = $Commands/Button
@onready var exit_btn = $Commands/Button2

@onready var battle_music = $BattleMusic
@onready var win_music = $WinMusic
@onready var accept_sfx = $AcceptSFX
@onready var commands = $Commands

signal textbox_closed

func _input(_event):
	var should_close_textbox =  Input.is_action_pressed("accept") and message.visible
	if should_close_textbox:
		message.hide()
		accept_sfx.play()
		emit_signal("textbox_closed")

func _ready():
	message.hide()
	set_process_input(true)
	fight_btn.grab_focus()
	init_player()
	init_enemy()
	commands.hide()
	await get_tree().create_timer(1).timeout
	show_message("Sb wants to fight!")
	await textbox_closed
	await get_tree().create_timer(0.5).timeout
	commands.show()
	fight_btn.grab_focus()

func init_player():
	player_mons = player_mons_scene.instantiate()
	player_mons.position = player_mons_pos.global_position
	p_name.text = player_mons.name_monster
	p_bar.max_value = player_mons.hp_total
	p_bar.value = player_mons.hp_total
	add_child(player_mons)

func init_enemy():
	enemy_mons = enemy_mons_scene.instantiate()
	enemy_mons.position = enemy_mons_pos.global_position
	e_name.text = enemy_mons.name_monster
	e_bar.max_value = enemy_mons.hp_total
	e_bar.value = enemy_mons.hp_total
	add_child(enemy_mons)

func show_message(text):
	message.show()
	message.text = text
	message.visible_ratio = 0
	animation_player.play("show_message")
	await animation_player.animation_finished
	await textbox_closed

func updateEnemy():
	e_bar.value = enemy_mons.hp_actual

func updatePlayer():
	p_bar.value = player_mons.hp_actual

func _on_button_focus_entered():
	
	fight_btn.icon = ResourceLoader.load("res://assets/graphics/select_icon.png")
	pass # Replace with function body.


func _on_button_focus_exited():
	accept_sfx.play()
	fight_btn.icon = null
	pass # Replace with function body.


func _on_button_2_focus_entered():
	exit_btn.icon = ResourceLoader.load("res://assets/graphics/select_icon.png")
	pass # Replace with function body.


func _on_button_2_focus_exited():
	accept_sfx.play()
	exit_btn.icon = null
	pass # Replace with function body.

func _on_button_pressed():
	commands.hide()
	show_message(player_mons.name_monster + " attacks!")
	await textbox_closed
	await get_tree().create_timer(0.2).timeout
	player_mons.attack(enemy_mons)
	show_message("%s deals %d!" % [player_mons.name_monster, player_mons.atk])
	await textbox_closed
	await get_tree().create_timer(0.2).timeout
	updateEnemy()
	if enemy_mons.hp_actual <= 0:
		battle_music.stop()
		win_music.play()
		show_message(player_mons.name_monster + " Wins!")
		await textbox_closed
		await get_tree().create_timer(1).timeout
		change_to_world()
	await get_tree().create_timer(0.2).timeout
	enemy_attack()

func change_to_world():
	get_tree().change_scene_to_file("res://scenes/main_level.tscn")

func enemy_attack():
	show_message(enemy_mons.name_monster + " attacks!")
	await textbox_closed
	await get_tree().create_timer(0.2).timeout
	enemy_mons.attack(player_mons)
	show_message("%s deals %d!" % [enemy_mons.name_monster, enemy_mons.atk])
	await textbox_closed
	updatePlayer()
	if player_mons.hp_actual <= 0:
		battle_music.stop()
		show_message(enemy_mons.name_monster + " Wins!")
	await get_tree().create_timer(1).timeout
	commands.show()
	fight_btn.grab_focus()


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://scenes/main_level.tscn")
