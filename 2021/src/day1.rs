#[aoc_generator(day1)]
pub fn to_vec(input: &str) -> Vec<i32> {
    input.lines().map(|l| l.parse().unwrap()).collect()
}

#[aoc(day1, part1)]
pub fn part1(input: &[i32]) -> i32 {
    let mut result = 0;
    let mut prev = None;
    for x in input {
        if let Some(y) = prev {
            if x > y {
                result += 1;
            }
        }
        prev = Some(x)
    }
    result
}

#[aoc(day1, part2)]
pub fn part2(input: &[i32]) -> i32 {
    let mut result = 0;
    let mut prev = None;
    for i in 0..input.len() {
        let mut x = 0;
        if let Some(x0) = input.get(i as usize) {
            if let Some(x1) = input.get((i + 1) as usize) {
                if let Some(x2) = input.get((i + 2) as usize) {
                    x = x0 + x1 + x2;
                }
            }
        }
        if let Some(y) = prev {
            if x > y {
                result += 1;
            }
        }
        prev = Some(x)
    }
    result
}
