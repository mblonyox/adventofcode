#[aoc_generator(day7)]
pub fn parse(input: &str) -> Vec<i32> {
    input.split(',').map(|n| n.parse().unwrap()).collect()
}

fn get_fuelv1(crabs: &Vec<i32>, pos: i32) -> i32 {
    crabs.iter().map(|c| (c - pos).abs()).sum()
}
fn get_fuelv2(crabs: &Vec<i32>, pos: i32) -> i32 {
    crabs
        .iter()
        .map(|c| {
            let diff = (c - pos).abs();
            (diff + 1) * diff / 2
        })
        .sum()
}

#[aoc(day7, part1)]
pub fn part1(input: &Vec<i32>) -> i32 {
    let start = *input.iter().min().unwrap();
    let end = *input.iter().max().unwrap();
    (start..=end)
        .map(|pos| get_fuelv1(input, pos))
        .min()
        .unwrap()
}

#[aoc(day7, part2)]
pub fn part2(input: &Vec<i32>) -> i32 {
    let start = *input.iter().min().unwrap();
    let end = *input.iter().max().unwrap();
    (start..=end)
        .map(|pos| get_fuelv2(input, pos))
        .min()
        .unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[allow(dead_code)]
    static SAMPLE_INPUT: &str = "16,1,2,0,4,2,7,1,2,14";

    #[test]
    fn sample_parse() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(input.len(), 10);
        assert_eq!(input.get(0), Some(&16));
        assert_eq!(input.get(9), Some(&14));
    }

    #[test]
    fn sample_part1() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part1(&input), 37);
    }

    #[test]
    fn sample_part2() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part2(&input), 168);
    }
}
