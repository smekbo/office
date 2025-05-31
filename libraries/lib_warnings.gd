extends Resource
class_name Warnings

static func placeholder_warning(object = null, resource = null):
	if resource != null:
		if resource.resource_path.contains("debug"): 
				push_warning("This is a debug/placeholder resource and should be replaced: " + resource.resource_path + " on " + str(object))
