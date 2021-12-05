use std::{collections::HashMap, convert::TryInto, iter::FromIterator};

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
pub struct Point {
    x: i32,
    y: i32,
}

impl<'a> FromIterator<&'a str> for Point {
    fn from_iter<I: IntoIterator<Item = &'a str>>(iter: I) -> Self {
        let mut nums = iter.into_iter();
        Point {
            x: nums.next().unwrap().parse().unwrap(),
            y: nums.next().unwrap().parse().unwrap(),
        }
    }
}

pub struct Line(Point, Point);

impl Line {
    pub fn is_horizontal(&self) -> bool {
        self.0.x == self.1.x
    }

    pub fn is_vertical(&self) -> bool {
        self.0.y == self.1.y
    }

    pub fn is_diagonal(&self) -> bool {
        (self.1.x - self.0.x).abs() == (self.1.y - self.0.y).abs()
    }

    pub fn points_inline(&self) -> Vec<Point> {
        let mut res = vec![];

        if self.is_horizontal() {
            let x = self.0.x;
            for y in if self.0.y > self.1.y {
                self.1.y..=self.0.y
            } else {
                self.0.y..=self.1.y
            } {
                res.push(Point{ x, y})
            }
        }

        if self.is_vertical() {
            let y = self.0.y;
            for x in if self.0.x > self.1.x {
                self.1.x..=self.0.x
            } else {
                self.0.x..=self.1.x
            } {
                res.push(Point{ x, y})
            }
        }

        if self.is_diagonal() {
            let (mut x, mut y) = (self.0.x, self.0.y);
            res.push(Point{x, y});
            while x != self.1.x || y != self.1.y {
                x += if x > self.1.x {-1} else {1};
                y += if y > self.1.y {-1} else {1};
                res.push(Point{x, y})
            }
        }

        res
    }
}

impl FromIterator<Point> for Line {
    fn from_iter<I: IntoIterator<Item = Point>>(iter: I) -> Self {
        let mut points = iter.into_iter();
        Line(points.next().unwrap(), points.next().unwrap())
    }
}

#[aoc_generator(day5)]
pub fn parse_input(input: &str) -> Vec<Line> {
    input
        .lines()
        .map(|l| l.split(" -> ").map(|p| p.split(',').collect()).collect())
        .collect()
}

#[aoc(day5, part1)]
pub fn part1(input: &Vec<Line>) -> i32 {
    let mut map_state = HashMap::new();
    input
        .iter()
        .filter(|l| l.is_horizontal() || l.is_vertical())
        .for_each(|l| {
            l.points_inline().iter().for_each(|p| {
                *map_state.entry(*p).or_insert(0) += 1;
            })
        });
    map_state
        .iter()
        .filter(|(_, n)| **n > 1)
        .count()
        .try_into()
        .unwrap()
}

#[aoc(day5, part2)]
pub fn part2(input: &Vec<Line>) -> i32 {
    let mut map_state = HashMap::new();
    input
        .iter()
        .filter(|l| l.is_horizontal() || l.is_vertical() || l.is_diagonal())
        .for_each(|l| {
            l.points_inline().iter().for_each(|p| {
                *map_state.entry(*p).or_insert(0) += 1;
            })
        });
    map_state
        .iter()
        .filter(|(_, n)| **n > 1)
        .count()
        .try_into()
        .unwrap()
}

#[cfg(test)]
mod test {
    use super::*;

    static SAMPLE_INPUT: &str = r#"0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2"#;

    #[test]
    fn sample_parse() {
        let input = parse_input(SAMPLE_INPUT);
        assert_eq!(input.len(), 10);
    }

    #[test]
    fn sample_part1() {
        let input = parse_input(SAMPLE_INPUT);
        assert_eq!(part1(&input), 5);
    }

    #[test]
    fn sample_part2() {
        let input = parse_input(SAMPLE_INPUT);
        assert_eq!(part2(&input), 12);
    }
}
