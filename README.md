# Godot Ocean Waves Package

**Compatible with Godot 4.7.**

An independently maintained package based on [GodotOceanWaves](https://github.com/2Retr0/GodotOceanWaves) by [2Retr0](https://github.com/2Retr0), designed to make the ocean rendering system easier to integrate into other Godot projects.

https://github.com/user-attachments/assets/a478d139-32eb-4957-92a7-2b6080fe9f46

## Changes in This Package

- Updated compatibility for Godot 4.7.
- Simplifies and consolidates the ocean system into a single, easy-to-import scene, making integration into other Godot projects straightforward.
- Uses a single cascade for simplicity and improved height consistency when sampling the ocean texture. The original project uses three cascades, and although each cascade could have its own parameters, this implementation uses a single cascade to simplify the setup and avoid the reduced accuracy observed when retrieving ocean height with multiple cascades. This also keeps the Inspector intuitive, exposing only one set of parameters to the user. While a single cascade may make texture repetition more noticeable at greater distances, the resulting quality is acceptable for the intended use case.
- Exposes only the essential parameters in the Inspector to provide a simple, plug-and-play experience with minimal setup. This reduces the amount of control available through the Inspector in favor of ease of use. Users who require more advanced customization can modify the underlying scripts and shaders.
- Uses `RenderingDevice.texture_get_data_async()` to retrieve displacement texture data asynchronously, avoiding a blocking readback on the main loop.
- A ready to use buoyancy script.

This repository is an independent derivative of the original project. The original implementation and its development history belong to their respective authors.

## Installation

1. Download or clone this repository.
2. Copy the `godot-ocean-waves` folder into your project's `res://packages/` directory.
3. Import the scene called `godot_ocean_waves.tscn` in the scene you want the ocean to appear.
4. Edit the values directly on the `GodotOceanWaves` node as you like.

The expected directory structure is:

```text
your-project/
└── packages/
    └── godot-ocean-waves/
        ├── GodotOceanWaves.tscn
        ├── ...
```

## Example Scene

The package includes `example.tscn`, a sample scene that demonstrates the ocean system in a working scene.

Use it to inspect the setup, explore the available rendering features, and understand how the ocean is integrated into a Godot scene before adding it to your own project.

Scene behavior and visual results may depend on the project's rendering settings, environment, and lighting configuration.

## Features and Modifications

## Parameters

- **`player`**: The player node used to shift the water mesh when moving into a new tile, allowing the ocean to follow the player and simulate an infinite ocean.
- **`water_color`**: The color used to tint the water material for different water appearances or artistic purposes.
- **`foam_color`**: The color used to tint the foam material for artistic purposes.
- **`wind_speed`**: The wind speed above the water, in meters per second. Higher values generally produce steeper, more chaotic waves with increased foam.
- **`wind_direction`**: The wind direction in degrees, affecting the direction of the waves. `0°` points along the positive X axis, while `90°` points along the positive Z axis.
- **`enable_audio`**: Enables or disables ocean and wind audio.
- **`enable_get_height`**: Enables or disables the `get_height()` function. Disable this option if you don't need to retrieve the water height at specific points. This avoids unnecessary GPU readback of the displacement texture, improving performance. Calling `get_height()` while this option is disabled will raise an error.

### Water Height Queries

The `godot_ocean_waves.gd` script provides a `get_height()` method for querying the water surface height at a world-space position:

```gdscript
get_height(world_pos: Vector3) -> float
```

This can be useful for gameplay systems that need to estimate the water surface height, such as floating objects, character interactions, and buoyancy calculations.

**Note:** Since `get_height()` relies on an asynchronous GPU readback, the returned height may be delayed by several frames (typically a few, depending on GPU workload and readback latency).

### Asynchronous Displacement Texture Readback

The package uses `RenderingDevice.texture_get_data_async()` to retrieve displacement texture data asynchronously.

Reading GPU texture data synchronously can introduce stalls while the CPU waits for GPU work to complete. An asynchronous readback helps avoid blocking the main loop while the data is being retrieved.

The exact performance impact depends on the hardware, rendering workload, and how the returned data is processed.

### Large-Scale Ocean Rendering

The project includes a clipmap-based ocean rendering approach designed to cover large areas, with a documented target range of approximately 8 km and multiple levels of detail (LOD).

Clipmaps allow the water surface to maintain detail near the camera while reducing geometric detail farther away.

Actual coverage and visual quality depend on the scene configuration and rendering settings.

### Waterline Fade

A waterline fade effect is included to help soften the transition around the water surface.

### Depth-Dependent Water Visibility

The water shader includes a depth-dependent color absorption parameter:

```glsl
uniform vec3 depth_color_consumption = vec3(7.5, 22.0, 38.0);
```

This parameter controls how water color changes with depth. Adjusting it can help achieve different visual styles, from clearer water to darker, more strongly absorbing water.

### Buoyancy Script

**Buoyancy System** — Custom GDScript implementation for Godot 4, designed to simulate buoyancy and water resistance for `RigidBody3D` objects using multiple buoyancy points.

The script calculates gravity and buoyancy forces at each point based on its depth below the water surface, while applying linear and angular drag to reduce movement and rotation when enough points are submerged.

**Parameters:**
- `ocean` — Reference to the Ocean node used to retrieve the water surface height
- `full_submersion_depth` — Depth required for a buoyancy point to reach maximum buoyancy
- `buoyancy_strength` — Multiplier controlling the strength of buoyancy
- `water_drag` — Controls linear water resistance
- `water_angular_drag` — Controls rotational water resistance
- `drag_activation_threshold` — Minimum number of submerged buoyancy points required to activate water resistance

**Setup:** Attach the script to a `RigidBody3D` and add a `FloatPoints` child node containing `Node3D` markers positioned around the hull.

## Attribution

- **[GodotOceanWaves](https://github.com/2Retr0/GodotOceanWaves)** by [2Retr0](https://github.com/2Retr0) — Original project, used and modified under the MIT License
- **[GodotOceanWaves fork](https://github.com/krautdev/GodotOceanWaves)** by [krautdev](https://github.com/krautdev) — Additional modifications incorporated into this project
- **[Pull Request #20](https://github.com/2Retr0/GodotOceanWaves/pull/20)** by [aallbrig](https://github.com/aallbrig) — Godot 4.6 compatibility fixes, adapted by me for Godot 4.7
- **[Watercraft Kit](https://kenney.nl/assets/watercraft-kit)** by [Kenney](https://kenney.nl/) — Ship asset, licensed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
