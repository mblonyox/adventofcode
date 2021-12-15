use std::collections::HashSet;

fn next_caves<'a>(
    maps: &'a Vec<(String, String)>,
    cave: &'a str,
) -> impl Iterator<Item = &'a String> {
    maps.iter().filter_map(move |(from, to)| {
        if cave == from {
            Some(to)
        } else if cave == to {
            Some(from)
        } else {
            None
        }
    })
}

fn cave_is_big(cave: &str) -> bool {
    cave.chars().all(|c| c.is_uppercase())
}

fn path_has_duplicate_small_cave(path: &[String]) -> bool {
    let mut set = HashSet::new();
    for cave in path {
        if !cave_is_big(cave) {
            if set.contains(cave) {
                return true;
            } else {
                set.insert(cave);
            }
        }
    }
    false
}

#[aoc_generator(day12)]
fn parse(input: &str) -> Vec<(String, String)> {
    input
        .lines()
        .map(|l| {
            let mut caves = l.split('-');
            (
                caves.next().unwrap().to_string(),
                caves.next().unwrap().to_string(),
            )
        })
        .collect()
}

#[aoc(day12, part1)]
pub fn part1(input: &Vec<(String, String)>) -> i32 {
    let mut paths = vec![vec![String::from("start")]];
    let mut result = 0;
    while let Some(path) = paths.pop() {
        for next in next_caves(input, path.last().unwrap()) {
            if next == "end" {
                result += 1;
                // println!("{}-end", path.join("-"));
            } else if cave_is_big(next) || !path.contains(next) {
                let mut new_path = path.clone();
                new_path.push(next.clone());
                paths.push(new_path);
            }
        }
    }
    result
}
#[aoc(day12, part2)]
pub fn part2(input: &Vec<(String, String)>) -> i32 {
    let mut paths = vec![vec![String::from("start")]];
    let mut result = 0;
    while let Some(path) = paths.pop() {
        for next in next_caves(input, path.last().unwrap()) {
            if next == "end" {
                result += 1;
                // println!("{}-end", path.join("-"));
            } else if next != "start"
                && (cave_is_big(next)
                    || !path.contains(next)
                    || !path_has_duplicate_small_cave(&path))
            {
                let mut new_path = path.clone();
                new_path.push(next.clone());
                paths.push(new_path);
            }
        }
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_SMALL_INPUT: &str = r#"start-A
start-b
A-c
A-b
b-d
A-end
b-end"#;

    static SAMPLE_MEDIUM_INPUT: &str = r#"dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"#;

    static SAMPLE_LARGE_INPUT: &str = r#"fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"#;

    #[test]
    fn sample_parse() {
        let small_input = parse(SAMPLE_SMALL_INPUT);
        let medium_input = parse(SAMPLE_MEDIUM_INPUT);
        let large_input = parse(SAMPLE_LARGE_INPUT);

        assert_eq!(small_input.len(), 7);
        assert_eq!(medium_input.len(), 10);
        assert_eq!(large_input.len(), 18);
    }

    #[test]
    fn sample_part1() {
        let small_input = parse(SAMPLE_SMALL_INPUT);
        let medium_input = parse(SAMPLE_MEDIUM_INPUT);
        let large_input = parse(SAMPLE_LARGE_INPUT);

        assert_eq!(part1(&small_input), 10);
        assert_eq!(part1(&medium_input), 19);
        assert_eq!(part1(&large_input), 226);
    }

    #[test]
    fn sample_part2() {
        let small_input = parse(SAMPLE_SMALL_INPUT);
        let medium_input = parse(SAMPLE_MEDIUM_INPUT);
        let large_input = parse(SAMPLE_LARGE_INPUT);

        assert_eq!(part2(&small_input), 36);
        assert_eq!(part2(&medium_input), 103);
        assert_eq!(part2(&large_input), 3509);
    }
}
