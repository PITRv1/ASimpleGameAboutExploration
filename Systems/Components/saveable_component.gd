extends Node
class_name SaveableComponent

@warning_ignore("unused_signal")
signal onDataLoaded

@export var save_id : String
@export var save_data_resource : Resource

var has_changed : bool = true

func _ready():
	if save_data_resource:
		save_data_resource = save_data_resource.duplicate(true)
	
	if save_id == "":
		save_id = _generate_default_id()
		#Generate unique ide for none defined stuff (allows for multiple auto generated unique save entries)s

func _generate_default_id():
	#For things that need to be saved but have multiple instance across the project we generate a hash based on the position of their parent
	var base_name : String
	if get_owner():
		base_name = scene_file_path.get_file().get_basename()
	else:
		base_name = "unnamed"
		
	var pos_hash := str(get_parent().global_position.snapped(Vector3(.1,.1,.1))) # low-precision hash
	return "%s_%s" % [base_name, pos_hash]
