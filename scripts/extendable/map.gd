extends Node2D
class_name Map

var projectiles: Node2D


func _ready() -> void:
	projectiles = Node2D.new()
	add_child(projectiles)


func add_projectile(projectile: Node2D) -> void:
	projectiles.add_child(projectile)
