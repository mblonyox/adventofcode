use regex::Regex;

#[derive(Debug, Clone, Copy)]
struct GameState {
    p1_pos: i32,
    p2_pos: i32,
    p1_score: i32,
    p2_score: i32,
    turn: i32,
}

impl GameState {
    fn new(pos: &(i32, i32)) -> Self {
        GameState {
            p1_pos: pos.0,
            p2_pos: pos.1,
            p1_score: 0,
            p2_score: 0,
            turn: 0,
        }
    }

    fn is_p1_wins(&self, goal: i32) -> bool {
        self.p1_score >= goal
    }

    fn is_p2_wins(&self, goal: i32) -> bool {
        self.p2_score >= goal
    }

    fn is_ended(&self, goal: i32) -> bool {
        self.is_p1_wins(goal) || self.is_p2_wins(goal)
    }

    fn moves(&mut self, rolls: i32) {
        if self.turn % 2 == 0 {
            self.p1_pos += rolls;
            self.p1_pos %= 10;
            if self.p1_pos == 0 {
                self.p1_pos = 10;
            }
            self.p1_score += self.p1_pos;
        } else {
            self.p2_pos += rolls;
            self.p2_pos %= 10;
            if self.p2_pos == 0 {
                self.p2_pos = 10;
            }
            self.p2_score += self.p2_pos;
        }
        self.turn += 1;
    }
}

#[aoc_generator(day21)]
fn parse(input: &str) -> (i32, i32) {
    let re = Regex::new(r"Player 1 starting position: (\d+)\nPlayer 2 starting position: (\d+)")
        .unwrap();
    let cap = re.captures(input).unwrap();
    (
        cap.get(1).unwrap().as_str().parse().unwrap(),
        cap.get(2).unwrap().as_str().parse().unwrap(),
    )
}

#[aoc(day21, part1)]
pub fn part1(input: &(i32, i32)) -> i32 {
    let mut state = GameState::new(input);
    let mut dice = (1..=100).cycle();
    while !state.is_ended(1000) {
        let rolls = dice.next().unwrap() + dice.next().unwrap() + dice.next().unwrap();
        state.moves(rolls);
    }
    state.p1_score.min(state.p2_score) * state.turn * 3
}

#[aoc(day21, part2)]
pub fn part2(input: &(i32, i32)) -> i64 {
    let state = GameState::new(input);

    fn universe_roll(game_state: GameState) -> (i64, i64) {
        if game_state.is_p1_wins(21) {
            return (1, 0);
        }
        if game_state.is_p2_wins(21) {
            return (0, 1);
        }
        let (mut p1_wins, mut p2_wins) = (0, 0);

        macro_rules! sub_roll {
            ($sum:expr, $prob:expr) => {{
                let mut gs = game_state.clone();
                gs.moves($sum);
                let (p1_win, p2_win) = universe_roll(gs);
                p1_wins += (p1_win * $prob);
                p2_wins += (p2_win * $prob);
            }};
        }
        // roll sum 3, probability 1/27
        sub_roll!(3, 1);
        // roll sum 4, probability 3/27
        sub_roll!(4, 3);
        // roll sum 5, probability 6/27
        sub_roll!(5, 6);
        // roll sum 6, probability 7/27
        sub_roll!(6, 7);
        // roll sum 7, probability 6/27
        sub_roll!(7, 6);
        // roll sum 8, probability 3/27
        sub_roll!(8, 3);
        // roll sum 7, probability 1/27
        sub_roll!(9, 1);

        (p1_wins, p2_wins)
    }

    let (p1_wins, p2_wins) = universe_roll(state);
    p1_wins.max(p2_wins)
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = "Player 1 starting position: 4\nPlayer 2 starting position: 8";

    #[test]
    fn sample_parse() {
        assert_eq!(parse(SAMPLE_INPUT), (4, 8));
    }

    #[test]
    fn sample_part1() {
        assert_eq!(part1(&parse(SAMPLE_INPUT)), 739785);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(&parse(SAMPLE_INPUT)), 444356092776315);
    }
}
