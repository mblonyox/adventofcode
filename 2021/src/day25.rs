#[derive(Debug, Clone)]
enum SeaCucumber {
    East,
    South,
}

#[derive(Debug, Clone)]
pub struct Map(Vec<Vec<Option<SeaCucumber>>>);

impl Map {
    fn row_num(&self) -> usize {
        self.0.len()
    }

    fn col_num(&self) -> usize {
        self.0[0].len()
    }

    fn moves_east(&mut self) -> i32 {
        let mut next_map = self.clone();
        let mut moves_num = 0;
        let row = self.row_num();
        let col = self.col_num();
        for y in 0..row {
            for x in 0..col {
                if let Some(SeaCucumber::East) = self.0[y][x] {
                    if let None = self.0[y][(x + 1) % col] {
                        next_map.0[y][(x + 1) % col] = next_map.0[y][x].take();
                        moves_num += 1;
                    }
                }
            }
        }
        *self = next_map;
        moves_num
    }

    fn moves_south(&mut self) -> i32 {
        let mut next_map = self.clone();
        let mut moves_num = 0;
        let row = self.row_num();
        let col = self.col_num();
        for y in 0..row {
            for x in 0..col {
                if let Some(SeaCucumber::South) = self.0[y][x] {
                    if let None = self.0[(y + 1) % row][x] {
                        next_map.0[(y + 1) % row][x] = next_map.0[y][x].take();
                        moves_num += 1;
                    }
                }
            }
        }
        *self = next_map;
        moves_num
    }

    fn moves(&mut self) -> i32 {
        self.moves_east() + self.moves_south()
    }
}

#[aoc_generator(day25)]
fn parse(input: &str) -> Map {
    Map(input
        .lines()
        .into_iter()
        .map(|l| {
            l.chars()
                .map(|c| match c {
                    '>' => Some(SeaCucumber::East),
                    'v' => Some(SeaCucumber::South),
                    _ => None,
                })
                .collect()
        })
        .collect())
}

#[aoc(day25, part1)]
pub fn part1(map: &Map) -> i32 {
    let mut map = map.clone();
    for i in 1.. {
        if map.moves() == 0 {
            return i;
        }
    }
    unreachable!()
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = r#"v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>"#;

    #[test]
    fn sample_parse() {
        let map = parse(SAMPLE_INPUT);
        assert_eq!(map.row_num(), 9);
        assert_eq!(map.col_num(), 10);
    }

    #[test]
    fn sample_part1() {
        assert_eq!(part1(&parse(SAMPLE_INPUT)), 58);
    }
}
