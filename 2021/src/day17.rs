use regex::Regex;

use crate::tools::cartesian::{Plane, Point};

struct Trajectory {
    plane: Plane,
    position: Point,
    vx: i32,
    vy: i32,
}

impl Iterator for Trajectory {
    type Item = Point;

    fn next(&mut self) -> Option<Self::Item> {
        self.position.moving(self.vx, self.vy);
        if self.position.is_on_plane(&self.plane) {
            if self.vx.is_positive() {
                self.vx -= 1;
            }
            self.vy -= 1;
            Some(self.position)
        } else {
            None
        }
    }
}

#[aoc_generator(day17)]
fn parse(input: &str) -> Plane {
    let re = Regex::new(r"target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)").unwrap();
    let caps = re.captures_iter(input).next().unwrap();
    let x1 = caps.get(1).unwrap().as_str().parse::<i32>().unwrap();
    let x2 = caps.get(2).unwrap().as_str().parse::<i32>().unwrap();
    let y1 = caps.get(3).unwrap().as_str().parse::<i32>().unwrap();
    let y2 = caps.get(4).unwrap().as_str().parse::<i32>().unwrap();
    Plane::new(x1.min(x2), y1.min(y2), x1.max(x2), y1.max(y2))
}

#[aoc(day17, part1)]
pub fn part1(target: &Plane) -> i32 {
    let min_y = target.min_y();
    min_y * (min_y + 1) / 2
}

#[aoc(day17, part2)]
pub fn part2(target: &Plane) -> i32 {
    let mut result = 0;
    let min_vx = ((target.min_x() * 2) as f64).sqrt() as i32;
    let max_vx = target.max_x();
    let min_vy = target.min_y();
    let max_vy = target.min_y().abs() - 1;
    let plane = Plane::new(0, target.min_y(), target.max_x(), i32::MAX);
    for vx in min_vx..=max_vx {
        for vy in min_vy..=max_vy {
            let mut traj = Trajectory {
                plane: plane,
                position: Point::default(),
                vx,
                vy,
            };
            if traj.any(|p| p.is_on_plane(&target)) {
                result += 1;
                // println!("{},{}", vx, vy);
            }
        }
    }

    result
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = r#"target area: x=20..30, y=-10..-5"#;

    #[test]
    fn sample_parse() {
        assert_eq!(parse(SAMPLE_INPUT), Plane::new(20, -10, 30, -5));
    }

    #[test]
    fn sample_part1() {
        let target = parse(SAMPLE_INPUT);
        assert_eq!(part1(&target), 45);
    }

    #[test]
    fn sample_part2() {
        let target = parse(SAMPLE_INPUT);
        assert_eq!(part2(&target), 112);
    }
}
