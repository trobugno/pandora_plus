class_name NPC extends CharacterBody2D

@export var npc : PPNPCEntity

var runtime_npc: PPRuntimeNPC

func _ready() -> void:
	runtime_npc = PPNPCManager.spawn_npc(npc)

func interact() -> void:
	print("Interacted with ", npc.get_npc_name())
	var active_quests = PPQuestManager.get_active_quests()
	PPNPCUtils.track_npc_interaction(active_quests, npc)
	
	var available_quests := runtime_npc.get_available_quests(PPQuestManager.get_completed_quest_ids())
	if available_quests:
		PPQuestManager.start_quest(available_quests[0])
	
