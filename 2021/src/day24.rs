use std::slice::Iter;

pub enum Var {
    W,
    X,
    Y,
    Z,
}

pub enum Ref {
    Var(Var),
    Val(i64),
}

pub enum Instruction {
    Inp(Var),
    Add(Var, Ref),
    Mul(Var, Ref),
    Div(Var, Ref),
    Mod(Var, Ref),
    Eql(Var, Ref),
}

#[derive(Debug, Default)]
struct Monad {
    w: i64,
    x: i64,
    y: i64,
    z: i64,
}

impl Monad {
    fn process(&mut self, insts: &[Instruction], input: &[i64]) {
        let mut input = input.iter();
        for inst in insts {
            self._execute(inst, &mut input);
        }
    }

    fn _execute(&mut self, inst: &Instruction, input: &mut Iter<i64>) {
        macro_rules! match_ref {
            ($ref:expr) => {
                match $ref {
                    Ref::Var(var) => match var {
                        Var::W => self.w,
                        Var::X => self.x,
                        Var::Y => self.y,
                        Var::Z => self.z,
                    },
                    Ref::Val(val) => *val,
                }
            };
        }

        match inst {
            Instruction::Inp(var) => match var {
                Var::W => self.w = *input.next().unwrap(),
                Var::X => self.x = *input.next().unwrap(),
                Var::Y => self.y = *input.next().unwrap(),
                Var::Z => self.z = *input.next().unwrap(),
            },
            Instruction::Add(var, r#ref) => match var {
                Var::W => self.w += match_ref!(r#ref),
                Var::X => self.x += match_ref!(r#ref),
                Var::Y => self.y += match_ref!(r#ref),
                Var::Z => self.z += match_ref!(r#ref),
            },
            Instruction::Mul(var, r#ref) => match var {
                Var::W => self.w *= match_ref!(r#ref),
                Var::X => self.x *= match_ref!(r#ref),
                Var::Y => self.y *= match_ref!(r#ref),
                Var::Z => self.z *= match_ref!(r#ref),
            },
            Instruction::Div(var, r#ref) => match var {
                Var::W => self.w /= match_ref!(r#ref),
                Var::X => self.x /= match_ref!(r#ref),
                Var::Y => self.y /= match_ref!(r#ref),
                Var::Z => self.z /= match_ref!(r#ref),
            },
            Instruction::Mod(var, r#ref) => match var {
                Var::W => self.w %= match_ref!(r#ref),
                Var::X => self.x %= match_ref!(r#ref),
                Var::Y => self.y %= match_ref!(r#ref),
                Var::Z => self.z %= match_ref!(r#ref),
            },
            Instruction::Eql(var, r#ref) => match var {
                Var::W => self.w = if self.w == match_ref!(r#ref) { 1 } else { 0 },
                Var::X => self.x = if self.x == match_ref!(r#ref) { 1 } else { 0 },
                Var::Y => self.y = if self.y == match_ref!(r#ref) { 1 } else { 0 },
                Var::Z => self.z = if self.z == match_ref!(r#ref) { 1 } else { 0 },
            },
        }
    }
}

#[aoc_generator(day24)]
fn parse(input: &str) -> Vec<Instruction> {
    input
        .lines()
        .map(|l| {
            let mut tokens = l.split_whitespace();
            macro_rules! match_token {
                (v: $token:expr) => {
                    match tokens.next().unwrap() {
                        "w" => Var::W,
                        "x" => Var::X,
                        "y" => Var::Y,
                        "z" => Var::Z,
                        _ => unreachable!(),
                    }
                };
                (r: $token:expr) => {
                    match tokens.next().unwrap() {
                        "w" => Ref::Var(Var::W),
                        "x" => Ref::Var(Var::X),
                        "y" => Ref::Var(Var::Y),
                        "z" => Ref::Var(Var::Z),
                        num => Ref::Val(num.parse::<i64>().unwrap()),
                    }
                };
            }
            match tokens.next().unwrap() {
                "inp" => Instruction::Inp(match_token!(v: tokens.next().unwrap())),
                "add" => Instruction::Add(
                    match_token!(v: tokens.next().unwrap()),
                    match_token!(r: tokens.next().unwrap()),
                ),
                "mul" => Instruction::Mul(
                    match_token!(v: tokens.next().unwrap()),
                    match_token!(r: tokens.next().unwrap()),
                ),
                "div" => Instruction::Div(
                    match_token!(v: tokens.next().unwrap()),
                    match_token!(r: tokens.next().unwrap()),
                ),
                "mod" => Instruction::Mod(
                    match_token!(v: tokens.next().unwrap()),
                    match_token!(r: tokens.next().unwrap()),
                ),
                "eql" => Instruction::Eql(
                    match_token!(v: tokens.next().unwrap()),
                    match_token!(r: tokens.next().unwrap()),
                ),
                _ => unreachable!(),
            }
        })
        .collect()
}

fn find_model_num(insts: &[Instruction], mut model_num: [i64; 14]) -> [i64; 14] {
    let mut stack = vec![];
    insts.chunks(18).enumerate().for_each(|(idx, sub_inst)| {
        match sub_inst.get(4) {
            Some(Instruction::Div(Var::Z, Ref::Val(1))) => {
                let add = match sub_inst.get(15) {
                    Some(Instruction::Add(Var::Y, Ref::Val(x))) => *x,
                    _ => unreachable!(),
                };
                stack.push((idx, add));
            }
            Some(Instruction::Div(Var::Z, Ref::Val(26))) => {
                let check = match sub_inst.get(5) {
                    Some(Instruction::Add(Var::X, Ref::Val(x))) => *x,
                    _ => unreachable!(),
                };
                let (prev, add) = stack.pop().unwrap();
                let w = model_num[prev] + add + check;
                if w > 9 {
                    model_num[prev] -= w - 9;
                    model_num[idx] = 9;
                } else if w < 1 {
                    model_num[prev] += 1 - w;
                    model_num[idx] = 1;
                } else {
                    model_num[idx] = w;
                }
            }
            _ => unreachable!(),
        };
    });
    model_num
}

#[aoc(day24, part1)]
pub fn part1(insts: &[Instruction]) -> i64 {
    let model_num = find_model_num(insts, [9; 14]);
    let mut monad = Monad::default();
    monad.process(insts, &model_num);
    if monad.z == 0 {
        model_num.map(|n| n.to_string()).join("").parse().unwrap()
    } else {
        panic!("Cannot find model number.")
    }
}

#[aoc(day24, part2)]
pub fn part2(insts: &[Instruction]) -> i64 {
    let model_num = find_model_num(insts, [1; 14]);
    let mut monad = Monad::default();
    monad.process(insts, &model_num);
    if monad.z == 0 {
        model_num.map(|n| n.to_string()).join("").parse().unwrap()
    } else {
        panic!("Cannot find model number.")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE_INPUT: &str = r#"inp w
add z w
mod z 2
div w 2
add y w
mod y 2
div w 2
add x w
mod x 2
div w 2
mod w 2"#;

    #[test]
    fn sample_parse() {
        let inst = parse(SAMPLE_INPUT);
        assert_eq!(inst.len(), 11);
    }

    #[test]
    fn sample_part1() {}

    #[test]
    fn sample_part2() {}
}
