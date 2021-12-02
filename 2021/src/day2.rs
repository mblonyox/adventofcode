pub enum SubmarineCommand {
    Forward(i32),
    Up(i32),
    Down(i32),
    None,
}

#[aoc_generator(day2)]
pub fn to_enum(input: &str) -> Vec<SubmarineCommand> {
    input
        .lines()
        .map(|l| {
            let mut args = l.split(" ");
            let cmd = args.next().unwrap();
            let val = args.next().unwrap().parse().unwrap();
            match cmd {
                "forward" => SubmarineCommand::Forward(val),
                "up" => SubmarineCommand::Up(val),
                "down" => SubmarineCommand::Down(val),
                _ => SubmarineCommand::None,
            }
        })
        .collect()
}

#[aoc(day2, part1)]
pub fn part1(input: &[SubmarineCommand]) -> i32 {
    let mut x_pos = 0;
    let mut y_pos = 0;
    for cmd in input {
        match cmd {
            SubmarineCommand::Forward(x) => x_pos += x,
            SubmarineCommand::Up(y) => y_pos -= y,
            SubmarineCommand::Down(y) => y_pos += y,
            _ => {}
        }
    }
    x_pos * y_pos
}

#[aoc(day2, part2)]
pub fn part2(input: &[SubmarineCommand]) -> i32 {
    let mut x_pos = 0;
    let mut y_pos = 0;
    let mut aim = 0;
    for cmd in input {
        match cmd {
            SubmarineCommand::Forward(x) => {
                x_pos += x;
                y_pos += aim * x;
            }
            SubmarineCommand::Up(y) => aim -= y,
            SubmarineCommand::Down(y) => aim += y,
            _ => {}
        }
    }
    x_pos * y_pos
}
