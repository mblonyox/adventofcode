use std::collections::{HashSet, VecDeque};

pub struct Grid(Vec<Vec<u8>>);

impl Grid {
    fn get_cell(&self, x: i32, y: i32) -> Option<&u8> {
        if x.is_negative() || y.is_negative() {
            return None;
        }
        if let Some(row) = self.0.get(y as usize) {
            return row.get(x as usize);
        }
        None
    }

    fn iter_cell(&self) -> impl Iterator<Item = ((i32, i32), u8)> + '_ {
        self.0
            .iter()
            .enumerate()
            .map(|(y, row)| {
                row.iter()
                    .enumerate()
                    .map(move |(x, &cell)| ((x as i32, y as i32), cell))
            })
            .flatten()
    }
}

#[aoc_generator(day9)]
fn parse(input: &str) -> Grid {
    Grid(
        input
            .lines()
            .map(|l| l.chars().map(|c| c.to_digit(10).unwrap() as u8).collect())
            .collect(),
    )
}

#[aoc(day9, part1)]
pub fn part1(input: &Grid) -> i32 {
    input
        .iter_cell()
        .map(|((x, y), cell)| {
            let adj = [(x, y - 1), (x, y + 1), (x - 1, y), (x + 1, y)];
            if adj.iter().all(|&(x, y)| match input.get_cell(x, y) {
                Some(&_cell) => cell < _cell,
                None => true,
            }) {
                return cell as i32 + 1;
            }
            0
        })
        .sum()
}

#[aoc(day9, part2)]
pub fn part2(input: &Grid) -> i32 {
    let mut cache = HashSet::<(i32, i32)>::new();
    let mut basins = input
        .iter_cell()
        .map(|(p, _)| {
            let mut count = 0;
            let mut queue = VecDeque::from([p]);
            while let Some((x, y)) = queue.pop_front() {
                if cache.contains(&(x, y)) {
                    continue;
                }
                match input.get_cell(x, y) {
                    Some(&c) => {
                        if c != 9 {
                            queue.push_back((x, y - 1));
                            queue.push_back((x, y + 1));
                            queue.push_back((x - 1, y));
                            queue.push_back((x + 1, y));
                            cache.insert((x, y));
                            count += 1;
                        }
                    }
                    None => {}
                }
            }
            count
        })
        .collect::<Vec<i32>>();
    basins.sort();
    basins.reverse();
    basins.iter().take(3).product()
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"2199943210
3987894921
9856789892
8767896789
9899965678"#;

    #[test]
    fn sample_parse() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(input.0.len(), 5)
    }

    #[test]
    fn sample_part1() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part1(&input), 15);
    }

    #[test]
    fn sample_part2() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part2(&input), 1134);
    }
}
