extends Node

const PROJECT_SCHEMA_VERSION := 1
const DIRECTION_COUNT := 16
const DIRECTION_NAMES := PackedStringArray([
	"E", "ESE", "SE", "SSE",
	"S", "SSW", "SW", "WSW",
	"W", "WNW", "NW", "NNW",
	"N", "NNE", "NE", "ENE"
])
const DIRECTION_ANGLES_DEG := PackedFloat32Array([
	0.0, 22.5, 45.0, 67.5,
	90.0, 112.5, 135.0, 157.5,
	180.0, 202.5, 225.0, 247.5,
	270.0, 292.5, 315.0, 337.5
])

signal sprite_librarian_ready


func _ready() -> void:
	assert(DIRECTION_NAMES.size() == DIRECTION_COUNT)
	assert(DIRECTION_ANGLES_DEG.size() == DIRECTION_COUNT)
	sprite_librarian_ready.emit()
	print("Sprite-Librarian internal extension initialized")
