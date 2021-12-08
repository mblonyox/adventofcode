use std::{collections::HashMap, iter::FromIterator};

#[derive(Debug, Clone)]
pub struct Entry {
    patterns: Vec<String>,
    output: Vec<String>,
    map: Option<HashMap<String, i32>>,
}

impl Entry {
    pub fn new(s: &str) -> Self {
        let mut p = s.split('|');
        let mut entry = Entry {
            patterns: p
                .next()
                .unwrap()
                .trim()
                .split_whitespace()
                .map(|s| s.to_string())
                .collect(),
            output: p
                .next()
                .unwrap()
                .trim()
                .split_whitespace()
                .map(|s| s.to_string())
                .collect(),
            map: None,
        };
        entry.deduct();
        entry
    }

    fn deduct(&mut self) -> &Self {
        let mut patterns = self.patterns.clone();

        let mut find_and_remove = |f: &dyn Fn(&String) -> bool| {
            if let Some(x) = patterns.iter().position(|p| f(p)) {
                let p = patterns.remove(x);
                return Some(p);
            }
            None
        };

        let p1 = find_and_remove(&|p| p.len() == 2).unwrap();
        let p7 = find_and_remove(&|p| p.len() == 3).unwrap();
        let p4 = find_and_remove(&|p| p.len() == 4).unwrap();
        let p8 = find_and_remove(&|p| p.len() == 7).unwrap();
        let p3 = find_and_remove(&|p| p.len() == 5 && p1.chars().all(|c| p.contains(c))).unwrap();
        let p9 = find_and_remove(&|p| p.len() == 6 && p4.chars().all(|c| p.contains(c))).unwrap();
        let p0 = find_and_remove(&|p| p.len() == 6 && p1.chars().all(|c| p.contains(c))).unwrap();
        let p6 = find_and_remove(&|p| p.len() == 6).unwrap();
        let p5 = find_and_remove(&|p| p.len() == 5 && p.chars().all(|c| p6.contains(c))).unwrap();
        let p2 = find_and_remove(&|p| p.len() == 5).unwrap();

        let map = HashMap::from_iter(vec![
            (p0.order(), 0),
            (p1.order(), 1),
            (p2.order(), 2),
            (p3.order(), 3),
            (p4.order(), 4),
            (p5.order(), 5),
            (p6.order(), 6),
            (p7.order(), 7),
            (p8.order(), 8),
            (p9.order(), 9),
        ]);

        self.map = Some(map);
        self
    }

    pub fn easy_digits(&self) -> i32 {
        let map = self.map.clone().unwrap();
        self.output
            .iter()
            .map(|s| map.get(&s.order()).unwrap())
            .filter(|&&x| x == 1 || x == 4 || x == 7 || x == 8)
            .count() as i32
    }

    pub fn output_value(&self) -> i32 {
        let map = self.map.clone().unwrap();
        let r = self
            .output
            .iter()
            .map(|s| map.get(&s.order()).unwrap().to_string())
            .collect::<String>();
        r.parse().unwrap()
    }
}

trait OrderedString {
    fn order(&self) -> Self;
}

impl OrderedString for String {
    fn order(&self) -> Self {
        let mut v = self.chars().collect::<Vec<char>>();
        v.sort();
        String::from_iter(v)
    }
}

#[aoc_generator(day8)]
pub fn parse<'a>(input: &'a str) -> Vec<Entry> {
    input.lines().map(|l| Entry::new(l)).collect()
}

#[aoc(day8, part1)]
pub fn part1(input: &Vec<Entry>) -> i32 {
    input.iter().map(|v| v.easy_digits()).sum()
}

#[aoc(day8, part2)]
pub fn part2(input: &Vec<Entry>) -> i32 {
    input.iter().map(|v| v.output_value()).sum()

}

#[cfg(test)]
mod tests {

    use super::*;

    static SAMPLE_INPUT: &str = r#"be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"#;

    #[test]
    fn sample_parse() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(input.len(), 10);
    }

    #[test]
    fn sample_part1() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part1(&input), 26)
    }

    #[test]
    fn sample_part2() {
        let input = parse(SAMPLE_INPUT);
        assert_eq!(part2(&input), 61229)
    }
}
