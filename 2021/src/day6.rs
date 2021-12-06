use std::collections::HashMap;

#[aoc_generator(day6)]
pub fn parse(input: &str) -> Vec<i64> {
  input.split(',').map(|s| s.parse().unwrap()).collect()
}

fn multiply(i: i64, t: i64, m: &mut HashMap<(i64, i64), i64>) -> i64 {
  match m.get(&(i, t)).map(|entry| entry.clone()) {
    Some(result) => result,
    None => {
      let mut res = 1;
      let mut t2 = t.clone();
      while t2 > i {
        res += multiply(8, t2 - i - 1, m);
        t2 -= 7;
      }
      m.insert((i, t), res.clone());
      res
    }
  }
}

#[aoc(day6, part1)]
pub fn part1(input: &Vec<i64>) -> i64 {
  let mut m = HashMap::new();
  input.iter().map(|i| multiply(*i, 80, &mut m)).sum()
}

#[aoc(day6, part2)]
pub fn part2(input: &Vec<i64>) -> i64 {
  let mut m = HashMap::new();
  input.iter().map(|i| multiply(*i, 256, &mut m)).sum()
}

#[cfg(test)]
mod tests {
  use super::*;

  #[allow(dead_code)]
  static SAMPLE_INPUT: &str = r#"3,4,3,1,2"#;

  #[test]
  fn sample_parse() {
    let input = parse(SAMPLE_INPUT);
    assert_eq!(input.len(), 5);
  }

  #[test]
  fn sample_part1() {
    let input = parse(SAMPLE_INPUT);
    assert_eq!(part1(&input), 5934);
  }

  #[test]
  fn sample_part2() {
    let input = parse(SAMPLE_INPUT);
    assert_eq!(part2(&input), 26984457539);
  }
}
