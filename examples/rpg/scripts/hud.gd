class_name HUD extends CanvasLayer

const UI_NOTIFICATION = preload("uid://bbf1gel8hepee")

@onready var ui_notification_locator: Control = $UINotificationLocator

func _ready() -> void:
	PPQuestManager.quest_added.connect(_on_quest_added)
	PPQuestManager.quest_completed.connect(_on_quest_completed)

func _on_quest_added(runtime_quest: PPRuntimeQuest) -> void:
	print("====================")
	print("> Started quest: ", runtime_quest.get_quest_name())
	
	var ui_notification := UI_NOTIFICATION.instantiate() as UINotification
	ui_notification_locator.add_child(ui_notification)
	ui_notification.show_up("New Quest", "Got new quest: %s" % runtime_quest.get_quest_name())

func _on_quest_completed(quest_id: String) -> void:
	var runtime_quest := PPQuestManager.find_quest(quest_id)
	print(">> Quest completed: ", runtime_quest.get_quest_name())
	
	# Get rewards using the new get_rewards() method
	var rewards := runtime_quest.get_rewards()
	
	var reward_string := ""
	print("\n=== Quest Rewards ===")
	for reward in rewards:
		print("\nReward: ", reward.get_reward_name())
	
		# Check reward type
		match reward.get_reward_type():
			PPQuestReward.RewardType.ITEM:
				print("  Type: Item")
				print("  Quantity: ", reward.get_quantity())
				
				# Get the reward entity if available
				var reward_entity := reward.get_reward_entity()
				if reward_entity:
					print("  Entity: ", reward_entity.get_entity_name())
					reward_string += "\n  Item: %s" % reward_entity.get_entity_name()
				reward_string += "\n  Quantity: %d" % reward.get_quantity()
			PPQuestReward.RewardType.CURRENCY:
				print("  Type: Currency")
				print("  Amount: ", reward.get_currency_amount())
				reward_string += "\n  Currency: %s" % reward.get_currency_amount()
	
	print("====================")
	
	var ui_notification := UI_NOTIFICATION.instantiate() as UINotification
	ui_notification_locator.add_child(ui_notification)
	ui_notification.show_up("Quest Completed", "Completed quest: %s\n\nRewards:%s" % [runtime_quest.get_quest_name(), reward_string])

func _on_location_reached(location: PPLocationEntity) -> void:
	for quest in PPQuestManager.get_active_quests():
		var objectives = quest.get_runtime_objectives()
		for i in range(objectives.size()):
			var obj = objectives[i]
			var obj_data = obj.get_quest_objective_instance()
			if obj_data.get_objective_type() == PPObjectiveEntity.ObjectiveType.REACH_LOCATION:
				var target = obj_data.get_target_reference().get_entity()
				if target.get_entity_id() == location.get_entity_id():
					obj.complete()
