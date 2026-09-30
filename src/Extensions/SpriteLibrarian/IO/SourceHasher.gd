class_name SpriteSourceHasher
extends RefCounted


static func sha256_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	var err := context.start(HashingContext.HASH_SHA256)
	if err != OK:
		push_error("Sprite-Librarian: failed to start SHA-256 context.")
		return ""
	err = context.update(bytes)
	if err != OK:
		push_error("Sprite-Librarian: failed to hash source bytes.")
		return ""
	return context.finish().hex_encode()


static func sha256_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		push_error("Sprite-Librarian: source file does not exist: %s" % path)
		return ""
	return sha256_bytes(FileAccess.get_file_as_bytes(path))
