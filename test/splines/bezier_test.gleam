import splines/bezier.{Bezier, new_2d}
import splines/lerp.{lerp2}
import vec/vec2

pub fn cubic_bezier_test() {
  // The matrix form should be equivalent to the de Casteljau method
  let points = [
    vec2.Vec2(-250.0, -250.0),
    vec2.Vec2(0.0, -225.0),
    vec2.Vec2(125.0, -200.0),
    vec2.Vec2(200.0, -100.0),
  ]
  let cubic = new_2d(points)
  let nary = Bezier(points:, interpolator: lerp2)
  assert bezier.sample(cubic, 0.0) == bezier.sample(nary, 0.0)
  assert bezier.sample(cubic, 0.25) == bezier.sample(nary, 0.25)
  assert bezier.sample(cubic, 0.5) == bezier.sample(nary, 0.5)
  assert bezier.sample(cubic, 0.75) == bezier.sample(nary, 0.75)
  assert bezier.sample(cubic, 1.0) == bezier.sample(nary, 1.0)
}
