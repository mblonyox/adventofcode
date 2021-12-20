use std::{
    collections::{HashMap, HashSet, VecDeque},
    ops::{Add, Sub},
};

#[derive(Debug, Clone, Copy)]
enum Rotation {
    None,
    X90,
    X180,
    X270,
    Y90,
    Y180,
    Y270,
    Z90,
    Z180,
    Z270,
    X90Y90,
    X90Y180,
    X90Y270,
    X90Z90,
    X90Z180,
    X90Z270,
    X180Y90,
    X180Y270,
    X180Z90,
    X180Z270,
    X270Y90,
    X270Y270,
    X270Z90,
    X270Z270,
}

impl Rotation {
    fn iter() -> impl Iterator<Item = &'static Self> {
        static ROTATIONS: [Rotation; 24] = [
            Rotation::None,
            Rotation::X90,
            Rotation::X180,
            Rotation::X270,
            Rotation::Y90,
            Rotation::Y180,
            Rotation::Y270,
            Rotation::Z90,
            Rotation::Z180,
            Rotation::Z270,
            Rotation::X90Y90,
            Rotation::X90Y180,
            Rotation::X90Y270,
            Rotation::X90Z90,
            Rotation::X90Z180,
            Rotation::X90Z270,
            Rotation::X180Y90,
            Rotation::X180Y270,
            Rotation::X180Z90,
            Rotation::X180Z270,
            Rotation::X270Y90,
            Rotation::X270Y270,
            Rotation::X270Z90,
            Rotation::X270Z270,
        ];
        ROTATIONS.iter()
    }

    fn rotate(&self, p: &Point3D) -> Point3D {
        let (x, y, z) = (p.x, p.y, p.z);
        match self {
            Rotation::None => Point3D { x, y, z },
            Rotation::X90 => Point3D { x, y: z, z: -y },
            Rotation::X180 => Point3D { x, y: -y, z: -z },
            Rotation::X270 => Point3D { x, y: -z, z: y },
            Rotation::Y90 => Point3D { x: -z, y, z: x },
            Rotation::Y180 => Point3D { x: -x, y, z: -z },
            Rotation::Y270 => Point3D { x: z, y, z: -x },
            Rotation::Z90 => Point3D { x: y, y: -x, z },
            Rotation::Z180 => Point3D { x: -x, y: -y, z },
            Rotation::Z270 => Point3D { x: -y, y: x, z },
            Rotation::X90Y90 => Point3D { x: y, y: z, z: x },
            Rotation::X90Y180 => Point3D { x: -x, y: z, z: y },
            Rotation::X90Y270 => Point3D { x: -y, y: z, z: -x },
            Rotation::X90Z90 => Point3D { x: z, y: -x, z: -y },
            Rotation::X90Z180 => Point3D {
                x: -x,
                y: -z,
                z: -y,
            },
            Rotation::X90Z270 => Point3D { x: -z, y: x, z: -y },
            Rotation::X180Y90 => Point3D { x: z, y: -y, z: x },
            Rotation::X180Y270 => Point3D {
                x: -z,
                y: -y,
                z: -x,
            },
            Rotation::X180Z90 => Point3D {
                x: -y,
                y: -x,
                z: -z,
            },
            Rotation::X180Z270 => Point3D { x: y, y: x, z: -z },
            Rotation::X270Y90 => Point3D { x: -y, y: -z, z: x },
            Rotation::X270Y270 => Point3D { x: y, y: -z, z: -x },
            Rotation::X270Z90 => Point3D { x: -z, y: -x, z: y },
            Rotation::X270Z270 => Point3D { x: z, y: x, z: y },
        }
    }
}

#[derive(Debug, Default, PartialEq, Eq, Clone, Copy, Hash)]
pub struct Point3D {
    x: i32,
    y: i32,
    z: i32,
}

impl Point3D {
    fn new(x: i32, y: i32, z: i32) -> Self {
        Self { x, y, z }
    }

    fn rotate(&self, r: &Rotation) -> Self {
        r.rotate(self)
    }
}

impl Add for Point3D {
    type Output = Self;

    fn add(self, rhs: Self) -> Self::Output {
        Point3D::new(self.x + rhs.x, self.y + rhs.y, self.z + rhs.z)
    }
}

impl Sub for Point3D {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        Point3D::new(self.x - rhs.x, self.y - rhs.y, self.z - rhs.z)
    }
}

fn find_overlap(base: &Vec<Point3D>, tgt: &Vec<Point3D>) -> Option<(Point3D, Rotation)> {
    for r in Rotation::iter() {
        let rotated = base.iter().map(|p| p.rotate(r)).collect::<Vec<Point3D>>();
        for p1 in &rotated {
            for p2 in tgt {
                let t = *p2 - *p1;
                let translated = rotated.iter().map(|p| *p + t).collect::<Vec<Point3D>>();
                let overlap_count = translated.iter().filter(|p| tgt.contains(p)).count();
                if overlap_count >= 12 {
                    return Some((t, *r));
                }
            }
        }
    }
    None
}

fn find_scanner_pairs(reports: &Vec<Vec<Point3D>>) -> HashMap<(usize, usize), (Point3D, Rotation)> {
    let mut pair_map = HashMap::new();
    for (index1, report1) in reports.iter().enumerate() {
        for (index2, report2) in reports.iter().enumerate() {
            if index1 == index2 {
                continue;
            }
            if let Some(transform) = find_overlap(report1, report2) {
                pair_map.insert((index1, index2), transform);
            }
        }
    }
    pair_map
}

fn find_shortest_pairs_chain<'a>(
    pair_keys: &Vec<&'a (usize, usize)>,
    i: usize,
) -> Vec<&'a (usize, usize)> {
    let mut queue = VecDeque::new();
    for key in pair_keys {
        if key.0 == i {
            queue.push_back(vec![*key]);
        }
    }
    while let Some(keys) = queue.pop_front() {
        let last_pair = keys.last().unwrap();
        if last_pair.1 == 0 {
            return keys;
        }
        for key in pair_keys {
            if key.0 == last_pair.1 {
                let mut new_pairs = keys.clone();
                new_pairs.push(key);
                queue.push_back(new_pairs);
            }
        }
    }
    unreachable!()
}

#[aoc_generator(day19)]
fn parse(input: &str) -> Vec<Vec<Point3D>> {
    input
        .split("\n\n")
        .map(|scanner| {
            scanner
                .lines()
                .skip(1)
                .map(|l| {
                    let mut nums = l.split(',');
                    Point3D::new(
                        nums.next().unwrap().parse().unwrap(),
                        nums.next().unwrap().parse().unwrap(),
                        nums.next().unwrap().parse().unwrap(),
                    )
                })
                .collect()
        })
        .collect()
}

#[aoc(day19, part1)]
pub fn part1(reports: &Vec<Vec<Point3D>>) -> i32 {
    let pair_map = find_scanner_pairs(reports);
    let mut set = HashSet::new();
    for p in reports.first().unwrap() {
        set.insert(*p);
    }
    let pair_keys = pair_map.keys().collect();
    for i in 1..reports.len() {
        let report = reports.get(i).unwrap();
        let chain_keys = find_shortest_pairs_chain(&pair_keys, i);
        for p in report {
            let mut p = p.clone();
            for k in &chain_keys {
                let (t, r) = pair_map.get(k).unwrap();
                p = p.rotate(r) + *t;
            }
            set.insert(p);
        }
    }

    set.len() as i32
}

#[aoc(day19, part2)]
pub fn part2(reports: &Vec<Vec<Point3D>>) -> i32 {
    let pair_map = find_scanner_pairs(reports);
    let pair_keys = pair_map.keys().collect();
    let mut scanner_positions = vec![Point3D::default()];
    for i in 1..reports.len() {
        let mut scanner_position = Point3D::default();
        let chain_keys = find_shortest_pairs_chain(&pair_keys, i);
        for k in &chain_keys {
            let (t, r) = pair_map.get(k).unwrap();
            scanner_position = scanner_position.rotate(r) + *t;
        }
        scanner_positions.push(scanner_position);
    }
    let mut max = 0;
    for p1 in &scanner_positions {
        for p2 in &scanner_positions {
            let v = *p2 - *p1;
            let distance = v.x.abs() + v.y.abs() + v.z.abs();
            if distance > max {
                max = distance;
            }
        }
    }
    max
}

#[cfg(test)]
mod tests {

    use super::*;

    static SAMPLE_INPUT: &str = r#"--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14"#;

    #[test]
    fn sample_parse() {
        let reports = parse(SAMPLE_INPUT);
        assert_eq!(reports.len(), 5);
    }

    #[test]
    fn sample_part1() {
        let reports = parse(SAMPLE_INPUT);
        assert_eq!(part1(&reports), 79);
    }

    #[test]
    fn sample_part2() {
        let reports = parse(SAMPLE_INPUT);
        assert_eq!(part2(&reports), 3621);
    }
}
