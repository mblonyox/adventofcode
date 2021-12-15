use std::collections::{HashMap, VecDeque};

use crate::tools::{cartesian::Point, grid::Grid};

fn get_lowest_risk_path(grid: &Grid<u8>) -> i32 {
    let start = Point::new(0, 0);
    let end = Point::new(grid.cols_num() as i32 - 1, grid.rows_num() as i32 - 1);
    let mut risk_map = HashMap::from([(start, 0)]);
    let mut queue = VecDeque::from([start]);
    while let Some(p) = queue.pop_front() {
        let dist = risk_map.get(&p).unwrap().to_owned();
        p.cross_adj().for_each(|p| {
            if let Some(&risk) = grid.get_point(&p) {
                let cur_risk = dist + risk as i32;
                let prev_risk = risk_map.entry(p).or_insert(i32::MAX);
                if cur_risk < *prev_risk {
                    *prev_risk = cur_risk;
                    queue.push_back(p);
                };
            }
        });
    }
    *risk_map.get(&end).unwrap()
}

#[aoc(day15, part1)]
pub fn part1(input: &str) -> i32 {
    let grid = input
        .lines()
        .map(|l| l.chars().map(|c| c as u8 - 0x30))
        .collect();
    get_lowest_risk_path(&grid)
}

#[aoc(day15, part2)]
pub fn part2(input: &str) -> i32 {
    let origin = input
        .lines()
        .map(|l| l.chars().map(|c| c as u8 - 0x30))
        .collect::<Grid<u8>>();
    let rows_num = origin.rows_num();
    let cols_num = origin.cols_num();
    let mut resized = vec![vec![0u8; cols_num * 5]; rows_num * 5];
    for (r, row) in resized.iter_mut().enumerate() {
        for (c, cell) in row.iter_mut().enumerate() {
            let mut new_cell = *origin.get(r % rows_num, c % cols_num).unwrap()
                + (r / rows_num) as u8
                + (c / cols_num) as u8;
            while new_cell > 9 {
                new_cell -= 9;
            }
            *cell = new_cell;
        }
    }
    let grid = resized.into_iter().map(|row| row.into_iter()).collect();

    get_lowest_risk_path(&grid)
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581"#;

    #[test]
    fn sample_part1() {
        assert_eq!(part1(SAMPLE_INPUT), 40);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(SAMPLE_INPUT), 315);
    }
}
