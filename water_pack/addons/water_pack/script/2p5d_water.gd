tool
extends "water.gd"

func set_colour(value):
	colour = value
	if material_override: material_override.set_shader_param("colour", value)
	if $down_water: $down_water.material_override.set_shader_param("water_colour", colour)
	
	return