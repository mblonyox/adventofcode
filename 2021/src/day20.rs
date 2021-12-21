#[derive(Debug, Clone)]
pub struct ImgEnhAlgo {
    algo: String,
    img: Vec<String>,
    outer: char,
}

impl ImgEnhAlgo {
    fn _expand_(&mut self) {
        if self.img.iter().any(|l| {
            l.chars().next().unwrap() != self.outer || l.chars().last().unwrap() != self.outer
        }) {
            let c = self.outer;
            self.img.iter_mut().for_each(|l| {
                l.insert(0, c);
                l.push(c)
            });
            let col_num = self.img.first().unwrap().len();
            let row = c.to_string().repeat(col_num);
            self.img.insert(0, row.clone());
            self.img.push(row);
        }
    }

    fn _get_char(&self, row: isize, col: isize) -> char {
        if row.is_negative() || col.is_negative() {
            self.outer
        } else {
            self.img
                .get(row as usize)
                .map(|l| l.chars().nth(col as usize).unwrap_or(self.outer))
                .unwrap_or(self.outer)
        }
    }

    fn _get_algo_index(&self, row: isize, col: isize) -> usize {
        let bits = [
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 0),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1),
        ]
        .iter()
        .map(|(dr, dc)| self._get_char(row + dr, col + dc))
        .map(|c| if c == '#' { '1' } else { '0' })
        .collect::<String>();

        usize::from_str_radix(&bits, 2).unwrap()
    }

    fn process(&mut self) {
        self._expand_();
        let row_num = self.img.len();
        let col_num = self.img.first().unwrap().len();
        let mut new_img = vec![String::with_capacity(col_num); row_num];
        for row in 0..row_num {
            let s = new_img.get_mut(row).unwrap();
            for col in 0..col_num {
                let pixel_index = self._get_algo_index(row as isize, col as isize);
                let pixel = self.algo.chars().nth(pixel_index).unwrap();
                s.push(pixel);
            }
        }
        self.img = new_img;
        self.outer = if self.outer == '.' {
            self.algo.chars().next().unwrap()
        } else {
            self.algo.chars().last().unwrap()
        }
    }

    fn lit_count(&self) -> i32 {
        if self.outer == '#' {
            i32::MAX
        } else {
            self.img
                .iter()
                .map(|row| row.chars().filter(|c| c == &'#').count())
                .sum::<usize>() as i32
        }
    }
}

#[aoc_generator(day20)]
fn parse(input: &str) -> ImgEnhAlgo {
    let mut iter = input.split("\n\n");
    ImgEnhAlgo {
        algo: iter.next().unwrap().to_string(),
        img: iter
            .next()
            .unwrap()
            .lines()
            .map(|l| l.to_string())
            .collect(),
        outer: '.',
    }
}

#[aoc(day20, part1)]
pub fn part1(input: &ImgEnhAlgo) -> i32 {
    let mut algo = input.clone();
    algo.process();
    algo.process();
    algo.lit_count()
}

#[aoc(day20, part2)]
pub fn part2(input: &ImgEnhAlgo) -> i32 {
    let mut algo = input.clone();
    for _ in 0..50 {
        algo.process();
    }
    algo.lit_count()
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = r#"..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###"#;

    #[test]
    fn sample_parse() {
        let iea = parse(SAMPLE_INPUT);
        assert_eq!(iea.algo.len(), 512);
        assert_eq!(iea.img.len(), 5);
    }

    #[test]
    fn sample_part1() {
        let iea = parse(SAMPLE_INPUT);
        assert_eq!(part1(&iea), 35);
    }

    #[test]
    fn sample_part2() {
        let iea = parse(SAMPLE_INPUT);
        assert_eq!(part2(&iea), 3351);
    }
}
