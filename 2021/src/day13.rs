use std::{collections::HashSet, str::FromStr};

#[derive(PartialEq, Eq, Hash, Clone, Copy)]
struct Dot(i32, i32);

struct DotParseError;

impl FromStr for Dot {
    type Err = DotParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut parts = s.split(',');
        Ok(Dot(
            parts.next().unwrap().parse().unwrap(),
            parts.next().unwrap().parse().unwrap(),
        ))
    }
}

impl Dot {
    fn flip(&self, ins: &Instruction) -> Dot {
        match *ins {
            Instruction::X(n) => {
                if self.0 > n {
                    Dot((2 * n) - self.0, self.1)
                } else {
                    Dot(self.0, self.1)
                }
            }
            Instruction::Y(n) => {
                if self.1 > n {
                    Dot(self.0, (2 * n) - self.1)
                } else {
                    Dot(self.0, self.1)
                }
            }
        }
    }
}

enum Instruction {
    X(i32),
    Y(i32),
}

struct InstructionParseError;

impl FromStr for Instruction {
    type Err = InstructionParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match &s[11..12] {
            "x" => Ok(Instruction::X(s[13..].parse().unwrap())),
            "y" => Ok(Instruction::Y(s[13..].parse().unwrap())),
            _ => Err(InstructionParseError),
        }
    }
}

pub struct Input {
    dots: Vec<Dot>,
    instructions: Vec<Instruction>,
}

#[aoc_generator(day13)]
fn parse(input: &str) -> Input {
    let mut parts = input.split("\n\n");
    let dots = parts
        .next()
        .unwrap()
        .lines()
        .map(|l| l.parse().ok().unwrap())
        .collect();
    let instructions = parts
        .next()
        .unwrap()
        .lines()
        .map(|l| l.parse().ok().unwrap())
        .collect();
    Input { dots, instructions }
}

#[aoc(day13, part1)]
pub fn part1(input: &Input) -> i32 {
    let ins = input.instructions.first().unwrap();
    input
        .dots
        .iter()
        .map(|d| d.flip(ins))
        .collect::<HashSet<Dot>>()
        .iter()
        .count() as i32
}

#[aoc(day13, part2)]
pub fn part2(input: &Input) -> String {
    let mut set = input.dots.iter().map(|d| *d).collect::<HashSet<Dot>>();

    for ins in &input.instructions {
        set = set.iter().map(|d| d.flip(ins)).collect();
    }

    let cols = set.iter().map(|d| d.0).max().unwrap();
    let rows = set.iter().map(|d| d.1).max().unwrap();
    
    "\n".to_owned() +
    &(0..=rows)
        .map(|y| {
            (0..=cols)
                .map(|x| if set.contains(&Dot(x, y)) { '#' } else { '.' })
                .collect::<String>()
        })
        .collect::<Vec<String>>()
        .join("\n")
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5"#;

    #[test]
    fn sample_parse() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(input.dots.len(), 18);
        assert_eq!(input.instructions.len(), 2);
    }

    #[test]
    fn sample_part1() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part1(&input), 17);
    }

    #[test]
    fn sample_part2() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part2(&input), r#"
#####
#...#
#...#
#...#
#####"#);
    }
}
