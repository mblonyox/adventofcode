#[aoc(day3, part1)]
pub fn part1(input: &str) -> i32 {
    let mut bit_count = vec![];
    for line in input.lines() {
        for (i, c) in line.chars().enumerate() {
            if bit_count.len() <= i {
                bit_count.push(0)
            }
            bit_count[i] += if c == '1' { 1 } else { -1 };
        }
    }
    let gamma = bit_count
        .iter()
        .map(|x| if x > &0 { 1 } else { 0 })
        .rev()
        .enumerate()
        .map(|(i, x)| x << i)
        .sum::<i32>();
    let epsilon = gamma
        ^ i32::from_str_radix(format!("{}", "1".repeat(bit_count.len())).as_str(), 2).unwrap();
    gamma * epsilon
}

#[aoc(day3, part2)]
pub fn part2(input: &str) -> i32 {
    let mut o2: Vec<Vec<char>> = input.lines().map(|l| l.chars().collect()).collect();
    let mut co2: Vec<Vec<char>> = o2.clone();
    let mut i = 0;
    while o2.len() > 1 {
        let most_o2 = o2
            .iter()
            .map(|x| if x[i] == '1' { 1 } else { -1 })
            .sum::<i32>();
        o2.retain(|x| {
            if most_o2 >= 0 {
                x[i] == '1'
            } else {
                x[i] == '0'
            }
        });
        i += 1;
    }
    let mut j = 0;
    while co2.len() > 1 {
        let most_co2 = co2
            .iter()
            .map(|x| if x[j] == '1' { 1 } else { -1 })
            .sum::<i32>();
        co2.retain(|x| {
            if most_co2 >= 0 {
                x[j] == '0'
            } else {
                x[j] == '1'
            }
        });
        j += 1;
    }
    i32::from_str_radix(
        o2.first().unwrap().into_iter().collect::<String>().as_str(),
        2,
    )
    .unwrap()
        * i32::from_str_radix(
            co2.first()
                .unwrap()
                .into_iter()
                .collect::<String>()
                .as_str(),
            2,
        )
        .unwrap()
}

mod tests {
    static  SAMPLE_INPUT: &'static str = r#"00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"#;

    #[test]
    pub fn sample_part1() {
        assert_eq!(
            super::part1(SAMPLE_INPUT),
            198
        )
    }

    #[test]
    pub fn sample_part2() {
      assert_eq!(
          super::part2(SAMPLE_INPUT),
          230
      )
  }
}
