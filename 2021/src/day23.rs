use std::collections::{HashMap, VecDeque};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Amphipod {
    A,
    B,
    C,
    D,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Burrow {
    halls: [Option<Amphipod>; 11],
    room_a: Vec<Amphipod>,
    room_b: Vec<Amphipod>,
    room_c: Vec<Amphipod>,
    room_d: Vec<Amphipod>,
    room_size: usize,
}

impl Burrow {
    fn from_hall_to_room(&self, index: usize) -> Result<(Burrow, i32), String> {
        macro_rules! check_pod {
            ($pod:path, $room:tt, $hall:expr, $mult:expr) => {{
                if self.$room.iter().any(|p| match p {
                    $pod => false,
                    _ => true,
                }) {
                    Err(format!("{} contains other Amphipod", stringify!($room)))
                } else if self.halls[index.min($hall) + 1..index.max($hall)]
                    .iter()
                    .any(|p| match p {
                        Some(_) => true,
                        _ => false,
                    })
                {
                    Err(format!("Path to {} is blocked", stringify!($room)))
                } else {
                    let mut burrow = self.clone();
                    let energy = ((index.max($hall) - index.min($hall) + burrow.room_size
                        - burrow.$room.len())
                        * $mult) as i32;
                    burrow.$room.push(burrow.halls[index].take().unwrap());
                    Ok((burrow, energy))
                }
            }};
        }
        if let Some(pod) = &self.halls[index] {
            match pod {
                Amphipod::A => check_pod!(Amphipod::A, room_a, 2, 1),
                Amphipod::B => check_pod!(Amphipod::B, room_b, 4, 10),
                Amphipod::C => check_pod!(Amphipod::C, room_c, 6, 100),
                Amphipod::D => check_pod!(Amphipod::D, room_d, 8, 1000),
            }
        } else {
            Err(format!("No Amphipod found in hall at index {}", index))
        }
    }

    fn from_room_to_hall(&self, room: char, index: usize) -> Result<(Burrow, i32), String> {
        if let Some(_) = self.halls[index] {
            return Err(format!("Hall at index {} is occupied.", index));
        }
        macro_rules! check_room {
            ($pod:path, $room:tt, $hall:expr) => {{
                if self.$room.is_empty() {
                    Err(format!("{} is empty", stringify!($room)))
                } else if self.$room.iter().all(|p| match p {
                    $pod => true,
                    _ => false,
                }) {
                    Err(format!("{} already completed.", stringify!($room)))
                } else if self.halls[index.min($hall)..index.max($hall)]
                    .iter()
                    .any(|p| match p {
                        Some(_) => true,
                        _ => false,
                    })
                {
                    Err(format!("Path from {} blocked", stringify!($room)))
                } else {
                    let mut burrow = self.clone();
                    let pod = burrow.$room.pop();
                    let mult = match pod.as_ref().unwrap() {
                        Amphipod::A => 1,
                        Amphipod::B => 10,
                        Amphipod::C => 100,
                        Amphipod::D => 1000,
                    };
                    let energy = ((index.max($hall) - index.min($hall) + burrow.room_size
                        - burrow.$room.len())
                        * mult) as i32;
                    burrow.halls[index] = pod;
                    Ok((burrow, energy))
                }
            }};
        }
        match room {
            'a' => check_room!(Amphipod::A, room_a, 2),
            'b' => check_room!(Amphipod::B, room_b, 4),
            'c' => check_room!(Amphipod::C, room_c, 6),
            'd' => check_room!(Amphipod::D, room_d, 8),
            _ => Err("Invalid room".to_string()),
        }
    }

    fn moves(&self) -> Vec<(Burrow, i32)> {
        let halls = vec![0usize, 1, 3, 5, 7, 9, 10];
        let rooms = vec!['a', 'b', 'c', 'd'];
        let moves_from_halls = halls
            .iter()
            .map(|&index| self.from_hall_to_room(index))
            .filter_map(|r| r.ok())
            .collect::<Vec<(Burrow, i32)>>();
        if moves_from_halls.is_empty() {
            rooms
                .iter()
                .flat_map(|&room| {
                    halls
                        .iter()
                        .map(|&index| self.from_room_to_hall(room, index))
                        .filter_map(|r| r.ok())
                        .collect::<Vec<(Burrow, i32)>>()
                })
                .collect()
        } else {
            moves_from_halls
        }
    }

    fn is_completed(&self) -> bool {
        return self.halls.iter().all(|opt| match opt {
            None => true,
            _ => false,
        }) && self.room_a.iter().all(|p| match p {
            Amphipod::A => true,
            _ => false,
        }) && self.room_b.iter().all(|p| match p {
            Amphipod::B => true,
            _ => false,
        }) && self.room_c.iter().all(|p| match p {
            Amphipod::C => true,
            _ => false,
        }) && self.room_d.iter().all(|p| match p {
            Amphipod::D => true,
            _ => false,
        });
    }
}

fn organize_pods(start: &Burrow) -> i32 {
    let mut result = i32::MAX;
    let mut moves_map = HashMap::new();
    let mut queue = VecDeque::new();
    moves_map.insert(start.clone(), 0);
    queue.push_back(start.clone());
    while let Some(burrow) = queue.pop_front() {
        let energy = *moves_map.get(&burrow).unwrap();
        if burrow.is_completed() {
            result = result.min(energy);
            continue;
        }
        for (next_burrow, move_energy) in burrow.moves() {
            if moves_map.contains_key(&next_burrow) {
                let prev_energy = *moves_map.get(&next_burrow).unwrap();
                if prev_energy > energy + move_energy {
                    moves_map.insert(next_burrow.clone(), energy + move_energy);
                    queue.push_back(next_burrow);
                }
            } else {
                moves_map.insert(next_burrow.clone(), energy + move_energy);
                queue.push_back(next_burrow);
            }
        }
    }
    result
}

#[aoc_generator(day23)]
fn parse(input: &str) -> Burrow {
    let parse_room = |indices: [usize; 2]| -> Vec<Amphipod> {
        indices
            .iter()
            .map(|&index| match input.chars().nth(index).unwrap() {
                'A' => Amphipod::A,
                'B' => Amphipod::B,
                'C' => Amphipod::C,
                'D' => Amphipod::D,
                _ => unreachable!(),
            })
            .collect()
    };
    Burrow {
        halls: [None; 11],
        room_a: parse_room([45, 31]),
        room_b: parse_room([47, 33]),
        room_c: parse_room([49, 35]),
        room_d: parse_room([51, 37]),
        room_size: 2,
    }
}

#[aoc(day23, part1)]
pub fn part1(input: &Burrow) -> i32 {
    organize_pods(input)
}

#[aoc(day23, part2)]
pub fn part2(input: &Burrow) -> i32 {
    let mut input = input.clone();
    input.room_a.insert(1, Amphipod::D);
    input.room_a.insert(2, Amphipod::D);
    input.room_b.insert(1, Amphipod::B);
    input.room_b.insert(2, Amphipod::C);
    input.room_c.insert(1, Amphipod::A);
    input.room_c.insert(2, Amphipod::B);
    input.room_d.insert(1, Amphipod::C);
    input.room_d.insert(2, Amphipod::A);
    input.room_size = 4;
    organize_pods(&input)
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = r#"#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########"#;

    #[test]
    fn sample_parse() {
        let burrow = parse(SAMPLE_INPUT);
        assert_eq!(burrow.halls.len(), 11);
        assert_eq!(burrow.room_a.len(), 2);
    }

    #[test]
    fn sample_part1() {
        assert_eq!(part1(&parse(SAMPLE_INPUT)), 12521);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(&parse(SAMPLE_INPUT)), 44169);
    }
}
