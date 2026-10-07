---
name: godot4-gdscript
description: Godot 4.x game development standards, GDScript conventions, Jolt 3D physics patterns, and project architecture.
---

# Godot 4.x & GDScript Development Guide

## 1. GDScript 2.0 Best Practices
- **Static Typing**: Always use explicit types for variables, parameters, and return types for performance and autocomplete.
  ```gdscript
  var speed: float = 5.0
  var target_position: Vector3 = Vector3.ZERO
  func calculate_velocity(input_dir: Vector3) -> Vector3:
      return input_dir * speed
  ```
- **Node References**: Prefer `@onready` annotations:
  ```gdscript
  @onready var camera: Camera3D = $Camera3D
  @onready var collision_shape: CollisionShape3D = $CollisionShape3D
  ```
- **Exports**: Use typed `@export` annotations:
  ```gdscript
  @export var move_speed: float = 6.0
  @export var jump_impulse: float = 4.5
  @export var character_mesh: MeshInstance3D
  ```
- **Signals**: Declare custom signals in past tense or action-oriented:
  ```gdscript
  signal health_changed(new_health: int, max_health: int)
  signal player_interacted(target: Node3D)
  ```

## 2. Project Architecture & Scene Tree
- **Composition over deep inheritance**: Prefer components (e.g. `HealthComponent`, `InteractionComponent`) attached to nodes.
- **Node Communication**:
  - Call down, signal up.
  - Parents call methods on children directly.
  - Children emit signals to notify parents or managers.
- **Singletons (Autoloads)**: Use sparingly for global state:
  - `GameManager`: Session state, pause management, scene transitions.
  - `AudioManager`: Global SFX / BGM routing.
  - `EventBus`: Decoupled global gameplay signals.

## 3. 3D & Jolt Physics Handling
- Always use `_physics_process(delta: float)` for movement and physics calculations.
- Use `CharacterBody3D` for player/NPC controllers:
  ```gdscript
  func _physics_process(delta: float) -> void:
      if not is_on_floor():
          velocity.y -= gravity * delta
      move_and_slide()
  ```
- Keep collision layers & masks clearly organized in Project Settings.

## 4. GDExtension / C++ Guidelines (When using C++)
- Use C++ / GDExtension for performance-critical bottlenecks (pathfinding grids, procedural generation, intensive math).
- Use GDScript for rapid prototyping, UI, game feel, and event wiring.

