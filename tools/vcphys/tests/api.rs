//! The API as BYOND sees it: text in, text out.
use vcphys::*;

fn call(command: fn(&[String]) -> Result<String, String>, args: &[&str]) -> Result<String, String> {
    command(&args.iter().map(|s| s.to_string()).collect::<Vec<_>>())
}

fn ok(command: fn(&[String]) -> Result<String, String>, args: &[&str]) -> String {
    call(command, args).unwrap_or_else(|e| panic!("{e}"))
}

/// A floor, and a two-link arm hanging off a box, knocked sideways.
fn scene() -> (String, String) {
    let world = ok(world_create, &["0", "-9.8"]);
    let ground = ok(body_create, &[&world, "0", "0", "-0.5", "0", "0", "0"]);
    ok(fixture_box, &[&world, &ground, "5", "0.5", "0", "0", "0", "0", "0.6", "0", "0"]);
    let upper = ok(body_create, &[&world, "2", "0", "1.5", "0", "0.05", "0.3"]);
    ok(fixture_box, &[&world, &upper, "0.1", "0.25", "0", "-0.25", "0", "1", "0.6", "0.1", "-1"]);
    let lower = ok(body_create, &[&world, "2", "0", "1.0", "0", "0.05", "0.3"]);
    ok(fixture_box, &[&world, &lower, "0.1", "0.25", "0", "-0.25", "0", "1", "0.6", "0.1", "-1"]);
    // An elbow that only bends one way, a quarter turn at most.
    ok(joint_revolute, &[&world, &upper, &lower, "0", "1.0", "0", "1.5708", "0.2"]);
    ok(body_impulse, &[&world, &lower, "0.8", "0"]);
    for _ in 0..90 {
        ok(world_step, &[&world, "0.016666667", "8", "3", "1"]);
    }
    let read = ok(world_read, &[&world]);
    (world, read)
}

#[test]
fn same_calls_same_result() {
    let (first_world, first) = scene();
    let (second_world, second) = scene();
    assert_eq!(first, second, "two identical runs came out different");
    ok(world_destroy, &[&first_world]);
    ok(world_destroy, &[&second_world]);
}

#[test]
fn joint_limit_holds() {
    let (world, read) = scene();
    // Bodies in handle order: ground (1), upper (2), lower (3). Field 3 is the angle.
    let angles: Vec<f32> = read.split(';').map(|body| body.split(' ').nth(3).unwrap().parse().unwrap()).collect();
    let bend = angles[2] - angles[1];
    assert!(bend >= -0.05 && bend <= 1.6208, "the elbow bent {bend} rad, outside its limits");
    ok(world_destroy, &[&world]);
}

#[test]
fn things_fall_and_land() {
    let world = ok(world_create, &["0", "-9.8"]);
    let ground = ok(body_create, &[&world, "0", "0", "-0.5", "0", "0", "0"]);
    ok(fixture_box, &[&world, &ground, "5", "0.5", "0", "0", "0", "0", "0.6", "0", "0"]);
    let crate_ = ok(body_create, &[&world, "2", "0", "3", "0", "0", "0"]);
    ok(fixture_box, &[&world, &crate_, "0.25", "0.25", "0", "0", "0", "1", "0.6", "0", "0"]);
    ok(world_step, &[&world, "0.016666667", "8", "3", "64"]);
    ok(world_step, &[&world, "0.016666667", "8", "3", "64"]);
    let y: f32 = ok(body_read, &[&world, &crate_]).split(' ').nth(2).unwrap().parse().unwrap();
    assert!((y - 0.25).abs() < 0.02, "the crate came to rest at {y}, not on the floor");
    ok(world_destroy, &[&world]);
}

#[test]
fn bad_calls_say_why() {
    assert!(call(world_step, &["999", "0.016", "8", "3", "1"]).unwrap_err().contains("no world"));
    let world = ok(world_create, &["0", "-9.8"]);
    assert!(call(body_read, &[&world, "42"]).unwrap_err().contains("no body"));
    assert!(call(body_create, &[&world, "7", "0", "0", "0", "0", "0"]).unwrap_err().contains("body type"));
    assert!(call(world_step, &[&world, "0.5", "8", "3", "1"]).is_err(), "a huge time step was allowed");
    assert!(call(world_create, &["NaN", "0"]).is_err(), "NaN gravity was allowed");
    assert!(call(fixture_box, &[&world]).unwrap_err().contains("missing"));
    ok(world_destroy, &[&world]);
    assert!(call(world_stats, &[&world]).unwrap_err().contains("no world"), "a destroyed world still answers");
}

#[test]
fn destroying_a_body_forgets_its_joints() {
    let world = ok(world_create, &["0", "-9.8"]);
    let a = ok(body_create, &[&world, "2", "0", "1", "0", "0", "0"]);
    ok(fixture_box, &[&world, &a, "0.1", "0.1", "0", "0", "0", "1", "0.5", "0", "0"]);
    let b = ok(body_create, &[&world, "2", "0", "0.8", "0", "0", "0"]);
    ok(fixture_box, &[&world, &b, "0.1", "0.1", "0", "0", "0", "1", "0.5", "0", "0"]);
    ok(joint_revolute, &[&world, &a, &b, "0", "0.9", "0", "0", "0"]);
    assert_eq!(ok(world_stats, &[&world]), "bodies=2 joints=1");
    ok(body_destroy, &[&world, &a]);
    assert_eq!(ok(world_stats, &[&world]), "bodies=1 joints=0");
    ok(world_destroy, &[&world]);
}
