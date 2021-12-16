#[derive(Debug)]
enum OperatorID {
    Sum,
    Product,
    Minimum,
    Maximum,
    GreaterThan,
    LessThan,
    Equal
}

#[derive(Debug)]
enum Packet {
    Literal {
        version: i64,
        value: i64,
    },
    Operator {
        version: i64,
        operator_id: OperatorID,
        subpackets: Vec<Packet>,
    },
}

impl Packet {
    fn get_version_sum(&self) -> i64 {
        match self {
            Packet::Literal { version, .. } => *version,
            Packet::Operator {
                version,
                subpackets,
                ..
            } => version + subpackets.iter().map(|p| p.get_version_sum()).sum::<i64>(),
        }
    }

    fn get_expression_value(&self) -> i64 {
        match self {
            Packet::Literal { value, .. } => *value,
            Packet::Operator {
                operator_id,
                subpackets,
                ..
            } => {
                let subpacket_values = subpackets.iter().map(|p| p.get_expression_value());
                macro_rules! check_equal {
                    ($predicate:tt) => {{
                        let mut iter = subpacket_values.take(2);
                        let first = iter.next().unwrap();
                        let second = iter.next().unwrap();
                        if $predicate(first, second) {1} else {0}
                    }}
                }
                match operator_id {
                OperatorID::Sum => subpacket_values.sum(),
                OperatorID::Product => subpacket_values.product(),
                OperatorID::Minimum => subpacket_values.min().unwrap(),
                OperatorID::Maximum => subpacket_values.max().unwrap(),
                OperatorID::GreaterThan => check_equal!((|a, b| a > b)),
                OperatorID::LessThan => check_equal!((|a, b| a < b)),
                OperatorID::Equal => check_equal!((|a, b| a == b)),
            }
        },
        }
    }
}

fn parse_binary(bits: &str) -> i64 {
    i64::from_str_radix(bits, 2).unwrap()
}

fn parse_literal_packet_value(mut bits: &str) -> (i64, &str) {
    let mut bin_str = String::new();
    loop {
        bin_str.push_str(&bits[1..5]);
        let cont = &bits[0..1];
        bits = &bits[5..];
        if cont == "0" {
            break;
        }
    }
    (parse_binary(&bin_str), bits)
}

fn parse_packet(bits: &str) -> (Packet, &str) {
    let version = parse_binary(&bits[0..3]);
    match &bits[3..6] {
        "100" => {
            let (value, rest) = parse_literal_packet_value(&bits[6..]);
            (Packet::Literal { version, value }, rest)
        }
        id => {
            let operator_id = match id {
                "000" => OperatorID::Sum,
                "001" => OperatorID::Product,
                "010" => OperatorID::Minimum,
                "011" => OperatorID::Maximum,
                "101" => OperatorID::GreaterThan,
                "110" => OperatorID::LessThan,
                "111" => OperatorID::Equal,
                _ => unreachable!("OperatorID must be one of the enum!")
            };
            let mut subpackets = vec![];
            let mut rest_bits = bits;
            match &bits[6..7] {
                "0" => {
                    let offset = (22 + parse_binary(&bits[7..22])) as usize;
                    let mut sub_bits = &bits[22..offset];
                    while !sub_bits.is_empty() {
                        let (subpacket, rest_sub_bits) = parse_packet(sub_bits);
                        subpackets.push(subpacket);
                        sub_bits = rest_sub_bits;
                    }
                    rest_bits = &bits[offset..];
                }
                "1" => {
                    let count = parse_binary(&bits[7..18]);
                    rest_bits = &bits[18..];
                    for _ in 0..count {
                        let (subpacket, bits_after) = parse_packet(rest_bits);
                        subpackets.push(subpacket);
                        rest_bits = bits_after;
                    }
                }
                _ => {}
            };
            (
                Packet::Operator {
                    version,
                    operator_id,
                    subpackets,
                },
                rest_bits,
            )
        }
    }
}

#[aoc_generator(day16)]
fn parse_input(input: &str) -> String {
    let mut output = String::new();
    input.trim_end().chars().for_each(|c| {
        let num = u8::from_str_radix(&c.to_string(), 16).unwrap();
        output.push_str(&format!("{:04b}", num))
    });
    output
}

#[aoc(day16, part1)]
pub fn part1(bits: &str) -> i64 {
    let (packet, _) = parse_packet(bits);
    packet.get_version_sum()
}

#[aoc(day16, part2)]
pub fn part2(bits: &str) -> i64 {
    let (packet, _) = parse_packet(bits);
    packet.get_expression_value()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sample_parse_input() {
        assert_eq!(parse_input("D2FE28\n"), "110100101111111000101000");
        assert_eq!(
            parse_input("38006F45291200"),
            "00111000000000000110111101000101001010010001001000000000"
        );
        assert_eq!(
            parse_input("EE00D40C823060"),
            "11101110000000001101010000001100100000100011000001100000"
        );
    }

    #[test]
    fn sample_parse_packet() {
        let (packet1, rest_bits1) = parse_packet("110100101111111000101000");
        assert!(matches!(
            packet1,
            Packet::Literal {
                version: 6,
                value: 2021
            }
        ));
        assert_eq!(rest_bits1, "000");
        let (packet2, _) = parse_packet("00111000000000000110111101000101001010010001001000000000");
        assert!(matches!(packet2, Packet::Operator { version: 1, .. }));
        if let Packet::Operator { operator_id, subpackets, .. } = packet2 {
            assert!(matches!(operator_id, OperatorID::LessThan));
            assert_eq!(subpackets.len(), 2);
            assert!(matches!(
                subpackets.first(),
                Some(Packet::Literal { value: 10, .. })
            ));
            assert!(matches!(
                subpackets.get(1),
                Some(Packet::Literal { value: 20, .. })
            ));
        }
        let (packet3, _) = parse_packet("11101110000000001101010000001100100000100011000001100000");
        assert!(matches!(packet3, Packet::Operator { version: 7, .. }));
        if let Packet::Operator { operator_id, subpackets, .. } = packet3 {
            assert!(matches!(operator_id, OperatorID::Maximum));
            assert_eq!(subpackets.len(), 3);
            assert!(matches!(
                subpackets.first(),
                Some(Packet::Literal { value: 1, .. })
            ));
            assert!(matches!(
                subpackets.get(1),
                Some(Packet::Literal { value: 2, .. })
            ));
            assert!(matches!(
                subpackets.get(2),
                Some(Packet::Literal { value: 3, .. })
            ));
        }
    }

    #[test]
    fn sample_part1() {
        assert_eq!(part1(&parse_input("8A004A801A8002F478")), 16);
        assert_eq!(part1(&parse_input("620080001611562C8802118E34")), 12);
        assert_eq!(part1(&parse_input("C0015000016115A2E0802F182340")), 23);
        assert_eq!(part1(&parse_input("A0016C880162017C3686B18A3D4780")), 31);
    }

    #[test]
    fn sample_part2() {
        assert_eq!(part2(&parse_input("C200B40A82")), 3);
        assert_eq!(part2(&parse_input("04005AC33890")), 54);
        assert_eq!(part2(&parse_input("880086C3E88112")), 7);
        assert_eq!(part2(&parse_input("CE00C43D881120")), 9);
        assert_eq!(part2(&parse_input("D8005AC2A8F0")), 1);
        assert_eq!(part2(&parse_input("F600BC2D8F")), 0);
        assert_eq!(part2(&parse_input("9C005AC2F8F0")), 0);
        assert_eq!(part2(&parse_input("9C0141080250320F1802104A08")), 1);
    }
}
