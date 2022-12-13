const input = await Deno.readTextFile("input.txt");

const stream = input.trim();

function isMarker(m: string, size: number): boolean {
  const s = new Set(m);
  return s.size === size;
}

let part1;

for (let i = 0; i < stream.length - 4; i++) {
  if (isMarker(stream.substring(i, i + 4), 4)) {
    part1 = i + 4;
    break;
  }
}

console.log(`Part 1: ${part1}`);

let part2;

for (let i = 0; i < stream.length - 14; i++) {
  if (isMarker(stream.substring(i, i + 14), 14)) {
    part2 = i + 14;
    break;
  }
}

console.log(`Part 2: ${part2}`);
