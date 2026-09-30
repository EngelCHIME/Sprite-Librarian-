class_name SpriteProjectSchema
extends RefCounted

const SCHEMA_VERSION := 1
const FRAME_WIDTH := 200
const FRAME_HEIGHT := 200

const DIRECTIONS := [
	{"name": "E", "angle_deg": 0.0},
	{"name": "ESE", "angle_deg": 22.5},
	{"name": "SE", "angle_deg": 45.0},
	{"name": "SSE", "angle_deg": 67.5},
	{"name": "S", "angle_deg": 90.0},
	{"name": "SSW", "angle_deg": 112.5},
	{"name": "SW", "angle_deg": 135.0},
	{"name": "WSW", "angle_deg": 157.5},
	{"name": "W", "angle_deg": 180.0},
	{"name": "WNW", "angle_deg": 202.5},
	{"name": "NW", "angle_deg": 225.0},
	{"name": "NNW", "angle_deg": 247.5},
	{"name": "N", "angle_deg": 270.0},
	{"name": "NNE", "angle_deg": 292.5},
	{"name": "NE", "angle_deg": 315.0},
	{"name": "ENE", "angle_deg": 337.5}
]


static func create_character_project(character_id: String, display_name: String) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"character": {
			"id": character_id,
			"display_name": display_name,
			"frame_size": {"width": FRAME_WIDTH, "height": FRAME_HEIGHT},
			"source_locked": true,
		},
		"directions": DIRECTIONS.duplicate(true),
		"animations": {},
		"source_manifest": {
			"algorithm": "sha256",
			"files": {}
		},
		"rig": null,
		"equipment": {},
		"palettes": {},
		"generation": {
			"providers": {},
			"provenance": []
		}
	}


static func canonical_animation_id(source_animation_id: String) -> String:
	if source_animation_id == "attack":
		return "ranged_attack"
	return source_animation_id
