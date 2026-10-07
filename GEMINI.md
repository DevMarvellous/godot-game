# Project Development Guidelines: Campus Christian Sketch

## Engine & Target
- **Engine**: Godot 4.x (with Jolt 3D Physics enabled)
- **Language**: GDScript 2.0 (strongly typed), optionally C++ via GDExtension for performance-critical modules.

## Architecture Guidelines
1. **Typed GDScript**:
   - Always define types for functions, variables, and return values.
2. **Node Hierarchy & Clean Scene Tree**:
   - Decouple systems using Godot signals.
   - Use dedicated components for re-usable behavior (movement, interaction, dialogue).
3. **Directory Structure**:
   - `res://scenes/` - `.tscn` scene files organized by domain (player, levels, ui, props).
   - `res://scripts/` - GDScript `.gd` code files matching scene structure.
   - `res://assets/` - 3D models (`.glb`/`.gltf`), textures, audio, fonts.
4. **Physics**:
   - Character movement belongs strictly in `_physics_process(delta)`.
   - Never alter physics state directly in `_process(delta)`.
