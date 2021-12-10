fn get_pair(c: char) -> char {
    match c {
        ')' => '(',
        ']' => '[',
        '}' => '{',
        '>' => '<',
        _ => '?',
    }
}

#[aoc(day10, part1)]
pub fn part1(input: &str) -> i32 {
    input
        .lines()
        .map(|l| -> i32 {
            let mut stack = Vec::new();
            for c in l.chars() {
                match c {
                    '(' | '[' | '{' | '<' => {
                        stack.push(c);
                    }
                    ')' | ']' | '}' | '>' => {
                        if let Some(p) = stack.pop() {
                            if p != get_pair(c) {
                                return match c {
                                    ')' => 3,
                                    ']' => 57,
                                    '}' => 1197,
                                    '>' => 25137,
                                    _ => 0,
                                };
                            }
                        }
                    }
                    _ => {}
                }
            }
            0
        })
        .sum()
}

#[aoc(day10, part2)]
pub fn part2(input: &str) -> i64 {
    let mut scores = input
        .lines()
        .map(|l| -> i64 {
            let mut stack = Vec::new();
            for c in l.chars() {
                match c {
                    '(' | '[' | '{' | '<' => {
                        stack.push(c);
                    }
                    ')' | ']' | '}' | '>' => {
                        if let Some(p) = stack.pop() {
                            if p != get_pair(c) {
                                return 0;
                            }
                        }
                    }
                    _ => {}
                }
            }
            let mut score = 0;
            while let Some(x) = stack.pop() {
                score *= 5;
                score += match x {
                    '(' => 1,
                    '[' => 2,
                    '{' => 3,
                    '<' => 4,
                    _ => 0,
                }
            }
            score
        })
        .filter(|&x| x > 0)
        .collect::<Vec<i64>>();

    scores.sort();

    scores.get(scores.len() / 2).unwrap().to_owned()
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"#;

    #[test]
    fn sample_part1() {
        assert_eq!(part1(SAMPLE_INPUT), 26397);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(SAMPLE_INPUT), 288957);
    }
}
