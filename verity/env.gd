extends RefCounted
class_name Env

## Loads key=value pairs from the project's .env file into the process environment.
## Copy .env.example to .env and fill in your local credentials.
static func load_env() -> void:
	# The Godot project lives in /verity, while the local .env lives at repo root.
	var env_path := ProjectSettings.globalize_path("res://../.env")
	if not FileAccess.file_exists(env_path):
		return

	var file := FileAccess.open(env_path, FileAccess.READ)
	if file == null:
		push_warning("Could not open .env file: %s" % env_path)
		return

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue

		var separator := line.find("=")
		if separator <= 0:
			continue

		var key := line.substr(0, separator).strip_edges()
		var value := line.substr(separator + 1).strip_edges()
		if value.length() >= 2 and ((value.begins_with("\"") and value.ends_with("\"")) or (value.begins_with("'") and value.ends_with("'"))):
			value = value.substr(1, value.length() - 2)
		OS.set_environment(key, value)

static func get_value(key: String, default_value: String = "") -> String:
	return OS.get_environment(key).strip_edges() if OS.has_environment(key) else default_value
