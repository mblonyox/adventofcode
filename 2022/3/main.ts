const input = await Deno.readTextFile("input.txt");

const rucksacks = input.trim().split("\n");

const part1 = rucksacks
  .map((l) => [l.substring(0, l.length / 2), l.substring(l.length / 2)])
  .map(([s1, s2]) => {
    for (const s of s1) {
      if (s2.includes(s)) return s;
    }
  }).map((x) => {
    if (!x) return 0;
    const p = x.charCodeAt(0);
    return p - (p >= 97 ? 96 : 38);
  }).reduce((t, x) => t + x, 0);

console.log(`Part 1: ${part1}`);

const part2 = rucksacks
  .reduce((t: string[][], x: string) => {
    const last = t.at(-1);
    if (!last || last.length === 3) t.push([x]);
    last?.push(x);
    return t;
  }, [])
  .map(([s1, s2, s3]) => {
    for (const s of s1) {
      if (s2.includes(s) && s3.includes(s)) return s;
    }
  }).map((x) => {
    if (!x) return 0;
    const p = x.charCodeAt(0);
    return p - (p >= 97 ? 96 : 38);
  }).reduce((t, x) => t + x, 0);

console.log(`Part 2: ${part2}`);
