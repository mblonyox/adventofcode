use regex::Regex;

fn nested_pair_count(txt: &str) -> i64 {
    let mut bracket = 0;
    for c in txt.chars() {
        match c {
            '[' => bracket += 1,
            ']' => bracket -= 1,
            _ => {}
        }
    }
    bracket
}

fn parse_pair_num(txt: &str) -> (i64, i64) {
    let mut split = (&txt[1..(txt.len() - 1)]).split(',');
    (
        split.next().unwrap().parse().unwrap(),
        split.next().unwrap().parse().unwrap(),
    )
}

fn add_number_to_left(txt: &str, offset: usize, value: i64) -> String {
    let mut output = txt.to_string();
    let num_re = Regex::new(r"\d+").unwrap();

    if let Some(mtch) = num_re.find_iter(&txt[..offset]).last() {
        let num = (&txt[mtch.range()]).parse::<i64>().unwrap();
        output.replace_range(mtch.range(), &format!("{}", num + value));
    }
    output
}

fn add_number_to_right(txt: &str, offset: usize, value: i64) -> String {
    let mut output = txt.to_string();
    let num_re = Regex::new(r"\d+").unwrap();

    if let Some(mtch) = num_re.find_at(&txt, offset) {
        let num = (&txt[mtch.range()]).parse::<i64>().unwrap();
        output.replace_range(mtch.range(), &format!("{}", num + value));
    }
    output
}

fn explode(txt: &str) -> Option<String> {
    let mut output = txt.to_string();
    let pair_re = Regex::new(r"\[\d+,\d+\]").unwrap();

    for m in pair_re.find_iter(&txt) {
        if nested_pair_count(&txt[..m.start()]) == 4 {
            let (left, right) = parse_pair_num(m.as_str());
            output.replace_range(m.range(), "0");
            output = add_number_to_left(&output, m.start(), left);
            output = add_number_to_right(&output, m.start() + 2, right);
            return Some(output);
        }
    }
    None
}

fn split(txt: &str) -> Option<String> {
    let mut output = txt.to_string();
    let num_re = Regex::new(r"\d{2,}").unwrap();
    if let Some(m) = num_re.find(txt) {
        let num = m.as_str().parse::<i64>().unwrap();
        output.replace_range(m.range(), &format!("[{},{}]", num / 2, (num + 1) / 2));
        return Some(output);
    }
    None
}

fn reduce(txt: &str) -> String {
    let mut output = txt.to_string();
    loop {
        if let Some(exploded) = explode(&output) {
            output = exploded;
            continue;
        }
        if let Some(splitted) = split(&output) {
            output = splitted;
            continue;
        }
        break;
    }
    output
}

fn magnitude(txt: &str) -> i64 {
    let mut output = txt.to_string();
    let pair_re = Regex::new(r"\[\d+,\d+\]").unwrap();
    while output.contains('[') {
        let current_text = output.clone();
        for m in pair_re.find_iter(&current_text) {
            let (left, right) = parse_pair_num(m.as_str());
            output = output.replace(m.as_str(), &(3 * left + 2 * right).to_string());
        }
    }
    output.parse::<i64>().unwrap()
}

fn addition(first: &str, second: &str) -> String {
    let output = format!("[{},{}]", first, second);
    reduce(&output)
}

#[aoc(day18, part1)]
pub fn part1(input: &str) -> i64 {
    let final_sum = input.lines().fold(String::new(), |mut t, l| {
        if t.is_empty() {
            t = l.to_string();
        } else {
            t = addition(&t, l);
        }
        t
    });
    magnitude(&final_sum)
}

#[aoc(day18, part2)]
pub fn part2(input: &str) -> i64 {
    let mut max = 0;
    let lines = input.lines().collect::<Vec<&str>>();
    for a in 0..lines.len() {
        for b in 0..lines.len() {
            if a == b {
                continue;
            }
            let final_sum = addition(lines[a], lines[b]);
            let mag = magnitude(&final_sum);
            if max < mag {
                max = mag;
            }
        }
    }
    max
}

#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"#;

    #[test]
    fn test_explode() {
        assert_eq!(
            explode("[[[[[9,8],1],2],3],4]"),
            Some("[[[[0,9],2],3],4]".to_string())
        );
        assert_eq!(
            explode("[7,[6,[5,[4,[3,2]]]]]"),
            Some("[7,[6,[5,[7,0]]]]".to_string())
        );
        assert_eq!(
            explode("[[6,[5,[4,[3,2]]]],1]"),
            Some("[[6,[5,[7,0]]],3]".to_string())
        );
        assert_eq!(
            explode("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"),
            Some("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]".to_string())
        );
        assert_eq!(
            explode("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"),
            Some("[[3,[2,[8,0]]],[9,[5,[7,0]]]]".to_string())
        );
    }

    #[test]
    fn test_split() {
        assert_eq!(
            split("[[[[0,7],4],[15,[0,13]]],[1,1]]"),
            Some("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]".to_string())
        );
        assert_eq!(
            split("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]"),
            Some("[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]".to_string())
        );
    }

    #[test]
    fn test_reduce() {
        assert_eq!(
            reduce("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"),
            "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
        );
    }

    #[test]
    fn test_magnitude() {
        assert_eq!(magnitude("[[1,2],[[3,4],5]]"), 143);
        assert_eq!(magnitude("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"), 1384);
        assert_eq!(magnitude("[[[[1,1],[2,2]],[3,3]],[4,4]]"), 445);
        assert_eq!(magnitude("[[[[3,0],[5,3]],[4,4]],[5,5]]"), 791);
        assert_eq!(magnitude("[[[[5,0],[7,4]],[5,5]],[6,6]]"), 1137);
        assert_eq!(
            magnitude("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"),
            3488
        );
    }

    #[test]
    fn sample_part1() {
        assert_eq!(part1(SAMPLE_INPUT), 4140);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(SAMPLE_INPUT), 3993);
    }
}
