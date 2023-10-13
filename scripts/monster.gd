extends Node2D

class_name Monster

@export var name_monster = "Monster"
@export var level = 1
@export var hp_total = 45
@export var hp_actual = 45
@export var atk = 2
@export var def = 2
@export var experience = 0
@export var exp_to_next_lvl = 50

func attack(monster:Monster):
	monster.hp_actual -= atk
