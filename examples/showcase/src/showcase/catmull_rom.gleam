import gleam/float
import gleam/int
import gleam/list
import splines
import tiramisu/scene
import vec/vec2
import vec/vec3

pub fn showcase() {
  let points = [
    vec2.Vec2(-250.0, -250.0),
    vec2.Vec2(0.0, -225.0),
    vec2.Vec2(125.0, -200.0),
    vec2.Vec2(200.0, -100.0),
    vec2.Vec2(-0.0, 0.0),
    vec2.Vec2(-100.0, 150.0),
    vec2.Vec2(-175.0, 75.0),
  ]
  let assert Ok(cmr) = splines.catmull_rom_2d(points)
  let max_t = list.length(points) - 3
  let num_segments = 10

  let debug_points =
    points
    |> list.index_map(fn(p, i) {
      scene.debug_point(
        id: "curve-point-" <> int.to_string(i),
        position: vec3.Vec3(p.x, p.y, 1.0),
        size: 5.0,
        color: 0x00ff00,
      )
    })

  let segments =
    int.range(from: { max_t * num_segments }, to: -1, with: [], run: fn(l, i) {
      [int.to_float(i) /. int.to_float(num_segments), ..l]
    })
    |> list.window_by_2()
    |> list.map(fn(t) {
      let #(t0, t1) = t
      let p0 = splines.sample(cmr, t0)
      let p1 = splines.sample(cmr, t1)
      scene.debug_line(
        id: "curve-segment-" <> float.to_string(float.to_precision(t0, 1)),
        from: vec3.Vec3(p0.x, p0.y, 1.5),
        to: vec3.Vec3(p1.x, p1.y, 1.5),
        color: 0xff0000,
      )
    })
  list.append(debug_points, segments)
}
