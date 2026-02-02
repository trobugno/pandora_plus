extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
	var save_slots := PPSaveManager.get_save_slots()
	if save_slots:
		var game_state := PPSaveManager.load_game(1) as PPGameState
		
		if game_state:
			var player_data := game_state.player_data as PPPlayerData
			if player_data:
				player.global_position.x = player_data.world_position.x
				player.global_position.y = player_data.world_position.y
				
			PPQuestManager.load_state(game_state)
			PPNPCManager.load_state(game_state)
			PPPlayerManager.load_state(game_state)

func _on_load_game_pressed() -> void:
	get_tree().reload_current_scene()

func _on_save_game_pressed() -> void:
	print("++++++++++++++++")
	print(">	 Saved Game 	<")
	PPSaveManager.save_game(1)

func _on_delete_save_pressed() -> void:
	print("----------------")
	print(">	 Reset Game 	<")
	PPSaveManager.delete_save(1)
	get_tree().reload_current_scene()
