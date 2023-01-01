const input = await Deno.readTextFile("input.txt");

type Packet = (number | Packet)[];

const pairs = input.trim().split("\n\n").map((p) =>
  p.split("\n").map((arr) => JSON.parse(arr) as Packet)
);

function compare(p1: Packet, p2: Packet): boolean | null {
  for (let i = 0; i < p1.length; i++) {
    const data1 = p1[i];
    const data2 = p2.at(i);
    if (data2 === undefined) return false;
    if (typeof data1 === "number") {
      if (data1 === data2) continue;
      if (typeof data2 === "number") return data1 < data2;
      const next = compare([data1], data2);
      if (next !== null) return next;
    } else {
      const next = compare(data1, typeof data2 === "number" ? [data2] : data2);
      if (next !== null) return next;
    }
  }
  if (p2.length > p1.length) return true;
  return null;
}

function part1() {
  return pairs.map((pair) => compare(pair[0], pair[1])).reduce(
    (total, value, index) => total + (value ? index + 1 : 0),
    0,
  );
}

console.log(`Part 1 : ${part1()}`);

function part2() {
  const allPackets = pairs.flat(1);
  const sorted = [...allPackets, [2], [6]].sort((a, b) => {
    const result = compare(a, b);
    if (result === null) return 0;
    return result ? -1 : 1;
  }).map((packet) => JSON.stringify(packet));
  const indexDivider2 = sorted.indexOf(
    JSON.stringify([2]),
  ) + 1;
  const indexDivider6 = sorted.indexOf(
    JSON.stringify([6]),
  ) + 1;
  return indexDivider2 * indexDivider6;
}

console.log(`Part 2 : ${part2()}`);
