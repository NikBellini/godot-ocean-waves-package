extends Node3D

@onready var water := $Water
@onready var ocean_audio_player := $OceanAudioPlayer
@onready var wind_audio_player := $WindAudioPlayer

## The player node used to shift the water mesh when moving into a new tile.
## This is required for the ocean to move with the player, simulating an infinite ocean.
@export var player: Node3D;
## The color of the water. This is used to tint the water material and can be used to simulate different water 
## or for artistic purposes.
@export_color_no_alpha var water_color: Color = Color(0.1, 0.15, 0.18):
	set(value):
		water_color = value
		if is_node_ready():
			water.water_color = value
## The color of the foam. This is used to tint the foam material and can be used to simulate different water
## or for artistic purposes.
@export_color_no_alpha var foam_color: Color = Color(0.73, 0.67, 0.62):
	set(value):
		foam_color = value
		if is_node_ready():
			water.foam_color = value
## The speed of the wind above the water in meters per second. Increasing makes waves steeper and more
## 'chaotic' and with more foam.
@export var wind_speed := 20.0:
	set(value):
		wind_speed = max(0.0001, value)
		if is_node_ready():
			for params in water.parameters:
				params.wind_speed = value
## The direction of the wind above the water in degrees. Increasing makes the waves to change direction.
## 0 degrees is along the positive X axis, 90 degrees is along the positive Z axis.
@export_range(-360, 360) var wind_direction := 0.0:
	set(value):
		wind_direction = value
		if is_node_ready():
			for params in water.parameters:
				params.wind_direction = value
## Whether or not to enable audio for the ocean and wind.
@export var enable_audio := true:
	set(value):
		enable_audio = value
		if is_node_ready():
			ocean_audio_player.stream_paused = not value
			wind_audio_player.stream_paused = not value
## Whether or not to enable the get_height() function. Disabling this can improve performance if you don't need
## to get the height of the water at a specific point. Disabling this will disable the GPU readback of the
## displacement texture, which is required for the get_height() function to work.
@export var enable_get_height := true:
	set(value):
		enable_get_height = value
		if is_node_ready():
			water.enable_get_height = value

var clipmap_tile_size := 1.0 # Not the smallest tile size, but one that reduces the amount of vertex jitter.
var previous_tile := Vector3i.MAX

func _ready() -> void:
	water.water_color = water_color
	water.foam_color = foam_color

	for params in water.parameters:
		params.wind_speed = wind_speed
		params.wind_direction = wind_direction

	ocean_audio_player.stream_paused = not enable_audio
	wind_audio_player.stream_paused = not enable_audio

	if not player:
		push_error('Player node is not assigned! Please assign a player to the GodotOceanWaves node.')
		return

func _physics_process(delta: float) -> void:
	# Shift water mesh whenever player moves into a new tile
	var tile := (Vector3(player.global_position.x, 0.0, player.global_position.z) / clipmap_tile_size).ceil()
	if not tile.is_equal_approx(previous_tile):
		water.global_position = tile * clipmap_tile_size
		previous_tile = tile

	# Vary audio samples based on the wind speed if the audio is enabled
	if enable_audio:
		ocean_audio_player.volume_db = lerpf(-30.0, 15.0, minf(wind_speed/15.0, 1.0))
		wind_audio_player.volume_db = lerpf(5.0, -30.0, minf(wind_speed/15.0, 1.0))

func get_height(world_pos: Vector3) -> float:
	return water.get_height(world_pos);
