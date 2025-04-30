extends Resource
class_name Quest

@export var questName : String
@export_enum("FetchQuest", "Bounty") var questType = "FetchQuest"
@export var rewardMoneyAmount : int = 0
@export_color_no_alpha var questColor
