<p align="center">
  <img src="https://github.com/user-attachments/assets/7b24ff45-b532-43d7-98b2-c44b41aec306" />
</p>

# Godot Boid's Implementation

---

### What is this:
- Implementation of Crag Raynolds' Boids algorithm - separation, alignment, cohesion.
- Separation defines a vector pointing away from neighbors.
- Alignment defines a vector aligned with neighbors' moving direction.
- Cohesion defines a vector pointing towards neighbor average location.
- Group management exists only in the form of spawning more actors.
- Also adds predators to periodically destroy boids.

### Heavily inspired by:
- [Useless Game Dev's "Just Boids" video](https://www.youtube.com/watch?v=6dJlhv3hfQ0)
- [Sebastian Lague's Coding Adventure](https://www.youtube.com/watch?v=bqtqltqcQhw)
- [Jorge Yanar's](https://github.com/jyanar) [Boid C++ Implementation](https://github.com/jyanar/Boids)
- [Daniel Shiffman Flocking Implementation @ processing.org](https://processing.org/examples/flocking.html)

### VFX:
- [Flytrap's Shader used on the Background](https://godotshaders.com/shader/perlin-procedural-water/).
