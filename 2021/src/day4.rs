use std::iter::FromIterator;

#[derive(Debug, Copy, Clone)]
pub struct Board {
    data: [[Option<u8>; 5]; 5],
}

impl Board {
    pub fn new(init_value: Option<u8>) -> Board {
        Board {
            data: [[init_value; 5]; 5],
        }
    }

    pub fn get(&self, row: usize, col: usize) -> Option<u8> {
        self.data[row][col]
    }

    pub fn mark(&mut self, num: u8) {
        for i in 0..5 {
          for j in 0..5 {
            if self.data[i][j] == Some(num) {
              self.data[i][j] = None;
            }
          }
        }
    }

    fn cols(&self) -> [[Option<u8>; 5]; 5] {
        let mut res = [[None; 5]; 5];
        for i in 0..5 {
            for j in 0..5 {
                res[i][j] = self.data[j][i].clone()
            }
        }
        res
    }

    pub fn is_bingo(&self) -> bool {
        self.data.iter().any(|r| r.iter().all(|c| c.is_none()))
            || self.cols().iter().any(|r| r.iter().all(|c| c.is_none()))
    }

    pub fn sum(&self) -> u32 {
      let mut res = 0;
      for r in self.data {
        for c in r {
          if let Some(x) = c {
            res += x as u32;
          }
        }
      }
      res
    }
}

impl FromIterator<Option<u8>> for Board {
    fn from_iter<I: IntoIterator<Item = Option<u8>>>(iter: I) -> Self {
        let mut board = Board::new(None);
        let mut iterator = iter.into_iter();
        for i in 0..5 {
            for j in 0..5 {
                board.data[i][j] = iterator.next().unwrap();
            }
        }
        board
    }
}

#[aoc_generator(day4)]
pub fn parse_input(input: &str) -> (Vec<u8>, Vec<Board>) {
    let mut lines = input.split("\n\n");
    let drawn = lines
        .next()
        .unwrap()
        .split(",")
        .map(|x| x.parse::<u8>().unwrap())
        .collect::<Vec<u8>>();

    let boards = lines
        .map(|l| {
            l.split_whitespace()
                .map(|x| x.parse::<u8>().ok())
                .collect::<Board>()
        })
        .collect();

    (drawn, boards)
}

#[aoc(day4, part1)]
pub fn part1(input: &(Vec<u8>, Vec<Board>)) -> u32 {
  let (drawn, mut boards) = input.clone();
  for num in drawn {
    boards.iter_mut().for_each(|b| b.mark(num));
    if let Some(x) = boards.iter().find(|b| b.is_bingo()) {
      return x.sum() * (num as u32)
    }
  }
  print!("{:#?}", boards);
  unreachable!()
}

#[aoc(day4, part2)]
pub fn part2(input: &(Vec<u8>, Vec<Board>)) -> u32 {
  let (drawn, mut boards) = input.clone();
  let mut last_board: Option<usize> = None;
  for num in drawn {
    boards.iter_mut().for_each(|b| b.mark(num));
    if last_board.is_none() {
      if boards.iter().filter(|b| !b.is_bingo()).count() == 1 {
        last_board = boards.iter().position(|b| !b.is_bingo());
      }
    } else if let Some(i) = last_board {
      let b = boards.get(i).unwrap();
      if b.is_bingo() {
        return b.sum() * (num as u32)
      }
    }
  }
  print!("{:#?}", boards);
  unreachable!()
}

mod tests {
    #[allow(dead_code)]
    static SAMPLE_INPUT: &str = r#"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"#;

    #[test]
    fn parse_sample() {
        let (drawns, boards)= super::parse_input(SAMPLE_INPUT);
        assert_eq!(drawns.len(), 27);
        assert_eq!(drawns[0], 7);
        assert_eq!(drawns[26], 1);
        // check Boards
        assert_eq!(boards.len(), 3);
        let board0 = boards.get(0).unwrap();
        assert_eq!(board0.get(0, 0), Some(22));
        assert_eq!(board0.get(4, 4), Some(19));
        let board2 = boards.get(2).unwrap();
        assert_eq!(board2.get(0, 0), Some(14));
        assert_eq!(board2.get(4, 4), Some(7));
    }

    #[test]
    fn part1_sample() {
      let input = super::parse_input(SAMPLE_INPUT);
      assert_eq!(super::part1(&input), 4512);
    }

    #[test]
    fn part2_sample() {
      let input = super::parse_input(SAMPLE_INPUT);
      assert_eq!(super::part2(&input), 1924);
    }
}
