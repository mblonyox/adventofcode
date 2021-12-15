use std::{collections::HashMap, str::FromStr};

pub struct InsertionPair(String, u8);

pub struct InsertionPairParseError;

impl FromStr for InsertionPair {
    type Err = InsertionPairParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut ins = s.split(" -> ");
        let pair = match ins.next() {
            Some(x) => x.to_string(),
            None => return Err(InsertionPairParseError),
        };
        let element = match ins.next() {
            Some(x) => x.bytes().next().unwrap(),
            None => return Err(InsertionPairParseError),
        };
        Ok(InsertionPair(pair, element))
    }
}

#[aoc_generator(day14)]
fn parse(input: &str) -> (String, Vec<InsertionPair>) {
    let mut parts = input.split("\n\n");
    let template = parts.next().unwrap().to_string();
    let pairs = parts
        .next()
        .unwrap()
        .lines()
        .map(|l| l.parse().ok().unwrap())
        .collect();
    (template, pairs)
}

fn process_insert(state: String, rules: &Vec<InsertionPair>) -> String {
    let mut new_state = state.as_bytes().to_vec();
    let mut indexes = vec![];
    for ins in rules {
        let pair = &ins.0;
        let element = ins.1;
        for i in 0..state.len() - 1 {
            if pair == &state[i..=i + 1] {
                indexes.push((i + 1, element));
            }
        }
    }
    indexes.sort_by(|a, b| b.0.cmp(&a.0));
    indexes.iter().for_each(|&(i, b)| {
        new_state.insert(i, b);
    });
    String::from_utf8(new_state).ok().unwrap()
}

#[aoc(day14, part1, string_match)]
pub fn part1_string_match(input: &(String, Vec<InsertionPair>)) -> i32 {
    let mut state = input.0.clone();
    for _ in 1..=10 {
        state = process_insert(state, &input.1);
    }
    let mut map = HashMap::new();
    state.chars().for_each(|c| *map.entry(c).or_insert(0) += 1);
    let max = map.values().max().unwrap();
    let min = map.values().min().unwrap();
    max - min
}

// #[aoc(day14, part2, string_match)]
pub fn part2_string_match(input: &(String, Vec<InsertionPair>)) -> i64 {
    let mut state = input.0.clone();
    for _ in 1..=40 {
        state = process_insert(state, &input.1);
    }
    let mut map = HashMap::new();
    state.chars().for_each(|c| *map.entry(c).or_insert(0) += 1);
    let max = map.values().max().unwrap();
    let min = map.values().min().unwrap();
    max - min
}

#[aoc(day14, part1, rules_map)]
pub fn part1_rules_map(input: &(String, Vec<InsertionPair>)) -> i32 {
    let rules_map = input
        .1
        .iter()
        .map(|ins| {
            let rule = ins.0.clone();
            let element = ins.1 as char;
            let next_rule1 = String::from_utf8(vec![rule.as_bytes()[0], ins.1]).ok().unwrap();
            let next_rule2 = String::from_utf8(vec![ins.1, rule.as_bytes()[1]]).ok().unwrap();
            (rule, (element, next_rule1, next_rule2))
        })
        .collect::<HashMap<String, (char, String, String)>>();
    let mut rule_counts = HashMap::new();
    for i in 0..input.0.len() - 1 {
        let s = &input.0[i..=i+1];
        if rules_map.keys().any(|k| k == s) {
            *rule_counts.entry(s.to_string()).or_insert(0) += 1;
        }
    }
    let mut el_counts = HashMap::new();
    for c in input.0.chars() {
        *el_counts.entry(c).or_insert(0) += 1
    }
    for _ in 1..=10 {
        let mut new_rule_counts = HashMap::new();
        for (key, count) in rule_counts {
            if let Some((c, r1, r2)) = rules_map.get(&key) {
                *el_counts.entry(*c).or_insert(0) += count;
                *new_rule_counts.entry(r1.clone()).or_insert(0) += count;
                *new_rule_counts.entry(r2.clone()).or_insert(0) += count;
            }
        }
        rule_counts = new_rule_counts;
    }
    let max = el_counts.values().max().unwrap();
    let min = el_counts.values().min().unwrap();
    max - min
}

#[aoc(day14, part2, rules_map)]
pub fn part2_rules_map(input: &(String, Vec<InsertionPair>)) -> i64 {
    let rules_map = input
        .1
        .iter()
        .map(|ins| {
            let rule = ins.0.clone();
            let element = ins.1 as char;
            let next_rule1 = String::from_utf8(vec![rule.as_bytes()[0], ins.1]).ok().unwrap();
            let next_rule2 = String::from_utf8(vec![ins.1, rule.as_bytes()[1]]).ok().unwrap();
            (rule, (element, next_rule1, next_rule2))
        })
        .collect::<HashMap<String, (char, String, String)>>();
    let mut rule_counts = HashMap::new();
    for i in 0..input.0.len() - 1 {
        let s = &input.0[i..=i+1];
        if rules_map.keys().any(|k| k == s) {
            *rule_counts.entry(s.to_string()).or_insert(0) += 1;
        }
    }
    let mut el_counts = HashMap::new();
    for c in input.0.chars() {
        *el_counts.entry(c).or_insert(0) += 1
    }
    for _ in 1..=40 {
        let mut new_rule_counts = HashMap::new();
        for (key, count) in rule_counts {
            if let Some((c, r1, r2)) = rules_map.get(&key) {
                *el_counts.entry(*c).or_insert(0) += count;
                *new_rule_counts.entry(r1.clone()).or_insert(0) += count;
                *new_rule_counts.entry(r2.clone()).or_insert(0) += count;
            }
        }
        rule_counts = new_rule_counts;
    }
    let max = el_counts.values().max().unwrap();
    let min = el_counts.values().min().unwrap();
    max - min
}


#[cfg(test)]
mod tests {
    use super::*;

    static SAMPLE_INPUT: &str = r#"NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"#;

    #[test]
    fn sample_parse() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(input.0, "NNCB");
        assert_eq!(input.1.len(), 16);
    }

    #[test]
    fn sample_process_input() {
        let input = parse(SAMPLE_INPUT);
        let rules = input.1;
        assert_eq!(process_insert(String::from("NNCB"), &rules), "NCNBCHB");
        assert_eq!(
            process_insert(String::from("NCNBCHB"), &rules),
            "NBCCNBBBCBHCB"
        );
        assert_eq!(
            process_insert(String::from("NBCCNBBBCBHCB"), &rules),
            "NBBBCNCCNBBNBNBBCHBHHBCHB"
        );
        assert_eq!(
            process_insert(String::from("NBBBCNCCNBBNBNBBCHBHHBCHB"), &rules),
            "NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB"
        );
    }

    #[test]
    fn sample_part1() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part1_string_match(&input), 1588);
        assert_eq!(part1_rules_map(&input), 1588);
    }

    #[test]
    fn sample_part2() {
        let input = parse(SAMPLE_INPUT);
        // assert_eq!(part2_string_match(&input), 2188189693529);
        assert_eq!(part2_rules_map(&input), 2188189693529);
    }
}
