import gleam/float
import gleam/time/duration
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import quaternion
import splines
import splines/b
import tiramisu/camera
import tiramisu/light
import tiramisu/material
import tiramisu/primitive
import tiramisu/scene
import tiramisu/tick
import tiramisu/transform
import vec/vec3
import vec/vec3f

import tiramisu

pub fn main() {
  let assert Ok(_) = tiramisu.register(tiramisu.builtin_extensions())

  let app = lustre.application(init:, update:, view:)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_flags: Nil) -> #(Model, effect.Effect(Msg)) {
  let points = [
    vec3.Vec3(-250.0, 100.0, -250.0),
    vec3.Vec3(0.0, 50.0, -225.0),
    vec3.Vec3(125.0, 125.0, -200.0),
    vec3.Vec3(200.0, 75.0, -100.0),
    vec3.Vec3(0.0, -50.0, 0.0),
    vec3.Vec3(-100.0, 0.0, 150.0),
    vec3.Vec3(-175.0, 100.0, 75.0),
  ]
  let assert Ok(path) = splines.basis_3d(points)
  let model = Model(time: duration.milliseconds(0), path:)
  #(model, tick.subscribe("main-scene", Tick))
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    Tick(t) -> #(
      Model(..model, time: duration.add(model.time, t.delta_time)),
      effect.none(),
    )
  }
}

fn view(model: Model) -> element.Element(Msg) {
  let camera_position = splines.sample(model.path, t_value(model.time))
  let look_at_q =
    quaternion.look_at(
      vec3.Vec3(0.0, 0.0, -1.0),
      vec3f.normalize(vec3f.subtract(vec3f.zero, camera_position)),
      vec3.Vec3(0.0, 1.0, 0.0),
    )

  html.div(
    [
      attribute.class(
        "flex flex-col bg-gray-950 text-white font-sans max-w-full",
      ),
    ],
    [
      tiramisu.scene(
        "main-scene",
        [
          scene.background_color(0x1a1a2e),
          attribute.width(800),
          attribute.height(600),
        ],
        [
          tiramisu.camera(
            "main-camera",
            [
              camera.fov(75.0),
              camera.active(True),
              transform.position(camera_position),
              transform.rotation_quaternion(look_at_q),
            ],
            [],
          ),
          tiramisu.primitive(
            "box-red",
            [
              material.phong(),
              primitive.box(vec3.Vec3(20.0, 10.0, 14.0)),
              transform.position(vec3.Vec3(0.0, 0.0, 0.0)),
              material.color(0xff0000),
            ],
            [],
          ),
          tiramisu.primitive(
            "box-blue",
            [
              material.phong(),
              primitive.box(vec3.Vec3(20.0, 10.0, 14.0)),
              transform.position(vec3.Vec3(50.0, 0.0, -75.0)),
              material.color(0x0000ff),
            ],
            [],
          ),
          tiramisu.primitive(
            "box-green",
            [
              material.phong(),
              primitive.box(vec3.Vec3(20.0, 10.0, 14.0)),
              transform.position(vec3.Vec3(-25.0, 0.0, 50.0)),
              material.color(0x00ff00),
            ],
            [],
          ),
          tiramisu.light(
            "ambient",
            [
              light.kind(light.Ambient),
              light.color(0xffffff),
              light.intensity(0.4),
            ],
            [],
          ),
          tiramisu.light(
            "sun",
            [
              light.kind(light.Directional),
              light.color(0xffffff),
              light.intensity(1.0),
              light.cast_shadow(True),
              transform.position(vec3.Vec3(5.0, 250.0, 7.0)),
            ],
            [],
          ),
        ],
      ),
    ],
  )
}

pub type Msg {
  Tick(tick.TickContext)
}

pub type Model {
  Model(
    time: duration.Duration,
    path: splines.Spline(b.BSpline(vec3f.Vec3f), vec3f.Vec3f),
  )
}

fn t_value(duration: duration.Duration) -> Float {
  let assert Ok(t) =
    duration.to_seconds(duration)
    |> float.modulo(4.0)
  t
}
