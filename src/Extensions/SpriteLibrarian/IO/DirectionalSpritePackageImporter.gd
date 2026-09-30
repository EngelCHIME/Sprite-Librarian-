class_name DirectionalSpritePackageImporter
extends RefCounted

const RUNTIME_MANIFEST := "runtime_sprites.json"


static func import_zip(zip_path: String) -> Dictionary:
	var reader := ZIPReader.new()
	var open_error := reader.open(zip_path)
	if open_error != OK:
		return _failure("Could not open ZIP: %s" % error_string(open_error))

	var runtime_bytes := reader.read_file(RUNTIME_MANIFEST)
	if runtime_bytes.is_empty():
		reader.close()
		return _failure("ZIP is missing %s" % RUNTIME_MANIFEST)

	var runtime = JSON.parse_string(runtime_bytes.get_string_from_utf8())
	if typeof(runtime) != TYPE_DICTIONARY:
		reader.close()
		return _failure("%s is not valid JSON." % RUNTIME_MANIFEST)

	var validation := _validate_runtime_manifest(runtime)
	if not validation["ok"]:
		reader.close()
		return validation

	var unit_id: String = runtime.get("unit", "unknown_character")
	var project := SpriteProjectSchema.create_character_project(unit_id, unit_id)
	project["source_package"] = {
		"type": "directional_sprite_zip",
		"path": zip_path,
		"runtime_manifest_sha256": SpriteSourceHasher.sha256_bytes(runtime_bytes)
	}

	var imported_frames := 0
	var animations: Dictionary = runtime["animations"]
	for source_animation_id in animations.keys():
		var canonical_id := SpriteProjectSchema.canonical_animation_id(source_animation_id)
		var source_directions: Dictionary = animations[source_animation_id]
		var animation := {
			"id": canonical_id,
			"source_animation_id": source_animation_id,
			"directions": {}
		}

		for direction in SpriteLibrarian.DIRECTION_NAMES:
			if not source_directions.has(direction):
				reader.close()
				return _failure(
					"Animation %s is missing direction %s." % [source_animation_id, direction]
				)

			var entry: Dictionary = source_directions[direction]
			var sheet_path: String = entry.get("sheet", "")
			var frame_count: int = int(entry.get("frames", 0))
			var frame_width: int = int(entry.get("frame_width", runtime["frame_width"]))
			var frame_height: int = int(entry.get("frame_height", runtime["frame_height"]))
			if sheet_path.is_empty() or frame_count <= 0:
				reader.close()
				return _failure(
					"Invalid sheet declaration for %s/%s." % [source_animation_id, direction]
				)

			var png_bytes := reader.read_file(sheet_path)
			if png_bytes.is_empty():
				reader.close()
				return _failure("ZIP is missing %s." % sheet_path)

			var sheet := Image.new()
			var png_error := sheet.load_png_from_buffer(png_bytes)
			if png_error != OK:
				reader.close()
				return _failure("Could not decode %s." % sheet_path)

			var expected_size := Vector2i(frame_width * frame_count, frame_height)
			if sheet.get_size() != expected_size:
				reader.close()
				return _failure(
					"Unexpected sheet size for %s: got %s, expected %s."
					% [sheet_path, sheet.get_size(), expected_size]
				)

			var frames: Array[Image] = []
			for frame_index in frame_count:
				var rect := Rect2i(frame_index * frame_width, 0, frame_width, frame_height)
				frames.append(sheet.get_region(rect))
				imported_frames += 1

			animation["directions"][direction] = {
				"source_sheet_path": sheet_path,
				"source_sheet_sha256": SpriteSourceHasher.sha256_bytes(png_bytes),
				"frame_width": frame_width,
				"frame_height": frame_height,
				"frame_count": frame_count,
				"frames": frames
			}
			project["source_manifest"]["files"][sheet_path] = {
				"sha256": SpriteSourceHasher.sha256_bytes(png_bytes),
				"animation": source_animation_id,
				"canonical_animation": canonical_id,
				"direction": direction,
				"frames": frame_count
			}

		project["animations"][canonical_id] = animation

	reader.close()
	project["import_summary"] = {
		"animations": project["animations"].size(),
		"directions_per_animation": SpriteLibrarian.DIRECTION_COUNT,
		"frames": imported_frames
	}
	return {"ok": true, "project": project}


static func _validate_runtime_manifest(runtime: Dictionary) -> Dictionary:
	if not runtime.has("animations"):
		return _failure("Runtime manifest has no animations dictionary.")
	if typeof(runtime["animations"]) != TYPE_DICTIONARY:
		return _failure("Runtime animations field must be a dictionary.")

	var frame_width := int(runtime.get("frame_width", 0))
	var frame_height := int(runtime.get("frame_height", 0))
	if frame_width <= 0 or frame_height <= 0:
		return _failure("Runtime frame dimensions are invalid.")

	var order = runtime.get("direction_order", [])
	if order.size() != SpriteLibrarian.DIRECTION_COUNT:
		return _failure("Runtime manifest must declare exactly 16 directions.")
	for i in SpriteLibrarian.DIRECTION_COUNT:
		if str(order[i]) != SpriteLibrarian.DIRECTION_NAMES[i]:
			return _failure(
				"Direction order mismatch at index %d: got %s, expected %s."
				% [i, str(order[i]), SpriteLibrarian.DIRECTION_NAMES[i]]
			)
	return {"ok": true}


static func _failure(message: String) -> Dictionary:
	push_error("Sprite-Librarian import: %s" % message)
	return {"ok": false, "error": message}
