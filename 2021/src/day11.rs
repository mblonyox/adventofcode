use std::collections::VecDeque;

fn get_adjacent(i: usize) -> Vec<usize> {
    let x = i as i32;
    vec![x - 12, x - 11, x - 10, x - 1, x + 1, x + 10, x + 11, x + 12]
        .iter()
        .filter(|&&x| x >= 0)
        .map(|&x| x as usize)
        .collect()
}

fn cycle(state: String) -> String {
    let mut bytes = state.as_bytes().to_owned();
    bytes.iter_mut().for_each(|b| {
        if *b >= 0x30 {
            *b += 1;
        }
    });
    let mut queue = bytes
        .iter()
        .enumerate()
        .filter_map(|(i, &b)| if b == 0x3a { Some(i) } else { None })
        .collect::<VecDeque<usize>>();
    while let Some(i) = queue.pop_front() {
        *bytes.get_mut(i).unwrap() = 0x30;
        get_adjacent(i).iter().for_each(|&i| {
            if let Some(b) = bytes.get_mut(i) {
                if *b > 0x30 {
                    *b += 1;
                }
                if *b == 0x3a {
                    queue.push_back(i);
                }
            }
        });
    }
    String::from_utf8(bytes).unwrap()
}

#[aoc(day11, part1)]
pub fn part1(input: &str) -> i32 {
    let mut state = input.to_string();
    let mut result = 0;
    for _ in 0..100 {
        state = cycle(state);
        result += state.chars().filter(|&c| c == '0').count() as i32
    }
    result
}

#[aoc(day11, part2)]
pub fn part2(input: &str) -> i32 {
    let mut state = input.to_string();
    let mut step = 0;
    loop {
        step += 1;
        state = cycle(state);
        if state.chars().filter(|&c| c == '0').count() == 100 {
            return step;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"#;

    #[test]
    fn sample_part1() {
        assert_eq!(part1(SAMPLE_INPUT), 1656);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(SAMPLE_INPUT), 195);
    }
}
