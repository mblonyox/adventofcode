const input = await Deno.readTextFile("input.txt");

const gcd = (a: number, b: number): number => a ? gcd(b % a, a) : b;

const lcm = (a: number, b: number) => a * b / gcd(a, b);

interface Monkey {
  items: number[];
  operation: string;
  value: number | "old";
  test_divisible: number;
  if_true: number;
  if_false: number;
}

const monkeys: Monkey[] = input.trim().split("\n\n").map((s: string) => {
  const lines = s.split("\n");
  const items = lines[1].substring(18).split(", ").map((x) => parseInt(x));
  const operation = lines[2].substring(23, 24);
  const value = lines[2].substring(25) === "old"
    ? "old"
    : parseInt(lines[2].substring(25));
  const test_divisible = parseInt(lines[3].substring(21));
  const if_true = parseInt(lines[4].substring(29));
  const if_false = parseInt(lines[5].substring(30));
  return {
    items,
    operation,
    value,
    test_divisible,
    if_true,
    if_false,
  };
});

function part1(monkeys: Monkey[]): number {
  const inspect_count = monkeys.map((_) => 0);
  const monkeys_items = monkeys.map((m) => [...m.items]);
  for (let i = 0; i < 20; i++) {
    for (let j = 0; j < monkeys.length; j++) {
      const monkey = monkeys[j];
      while (monkeys_items[j].length) {
        let worry_level = monkeys_items[j].shift()!;
        const value = monkey.value === "old" ? worry_level : monkey.value;
        switch (monkey.operation) {
          case "+":
            worry_level += value;
            break;
          case "*":
            worry_level *= value;
            break;
          default:
            break;
        }
        worry_level = Math.floor(worry_level / 3);
        monkeys_items[
          worry_level % monkey.test_divisible == 0
            ? monkey.if_true
            : monkey.if_false
        ].push(worry_level);
        inspect_count[j]++;
      }
    }
  }

  inspect_count.sort((a, b) => b - a);

  return inspect_count[0] * inspect_count[1];
}

console.log(`Part 1 : ${part1(monkeys)}`);

function part2(monkeys: Monkey[]): number {
  const inspect_count = monkeys.map((_) => 0);
  const monkeys_items = monkeys.map((m) => [...m.items]);

  const kpk = monkeys.map((m) => m.test_divisible).reduce(lcm);

  for (let i = 0; i < 10000; i++) {
    for (let j = 0; j < monkeys.length; j++) {
      const monkey = monkeys[j];
      while (monkeys_items[j].length) {
        let worry_level = monkeys_items[j].shift()!;
        const value = monkey.value === "old" ? worry_level : monkey.value;
        switch (monkey.operation) {
          case "+":
            worry_level += value;
            break;
          case "*":
            worry_level *= value;
            break;
          default:
            break;
        }
        monkeys_items[
          worry_level % monkey.test_divisible == 0
            ? monkey.if_true
            : monkey.if_false
        ].push(worry_level % kpk);
        inspect_count[j]++;
      }
    }
  }

  inspect_count.sort((a, b) => b - a);

  return inspect_count[0] * inspect_count[1];
}

console.log(`Part 2 : ${part2(monkeys)}`);
