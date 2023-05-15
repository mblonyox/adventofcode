const input = await Deno.readTextFile("input.txt");

class Point {
  constructor(private _x: number, private _y: number) {
  }

  get x() {
    return this._x;
  }
  get y() {
    return this._y;
  }

  static fromString(str: string) {
    const [x, y] = str.split(",").map((x) => parseInt(x));
    return new Point(x, y);
  }

  toString() {
    return `${this.x},${this.y}`;
  }
}

function init(input: string): [Set<string>, number] {
  const paths = input.trim().split("\n").map((line) =>
    line.split(" -> ").map((p) => Point.fromString(p))
  );

  const depth = Math.max(...paths.flatMap((line) => line.map((p) => p.y)));

  const rocks = new Set<string>();
  for (const path of paths) {
    const start = path.pop();
    if (!start) continue;
    let { x, y } = start;
    rocks.add(`${x},${y}`);
    while (path.length) {
      const next = path.pop();
      if (!next) continue;
      while (x !== next.x) {
        x += x < next.x ? 1 : -1;
        rocks.add(`${x},${y}`);
      }
      while (y !== next.y) {
        y += y < next.y ? 1 : -1;
        rocks.add(`${x},${y}`);
      }
    }
  }

  return [rocks, depth];
}

function part1(input: string) {
  const [rocks, depth] = init(input);
  const sands = new Set<string>();
  let free = false;
  while (!free) {
    let x = 500, y = 0, stop = false;
    while (!stop) {
      stop = true;
      for (const dx of [0, -1, 1]) {
        const p = `${x + dx},${y + 1}`;
        if (!stop || rocks.has(p) || sands.has(p)) continue;
        x += dx;
        y += 1;
        stop = false;
      }
      if (y > depth) {
        free = true;
        break;
      }
    }
    if (stop) sands.add(`${x},${y}`);
  }
  return sands.size;
}

console.log(`Part 1 : ${part1(input)}`);

function part2(input: string) {
  const [rocks, depth] = init(input);
  const sands = new Set<string>();
  while (!sands.has(`500,0`)) {
    let x = 500, y = 0, stop = false;
    while (!stop) {
      stop = true;
      for (const dx of [0, -1, 1]) {
        const p = `${x + dx},${y + 1}`;
        if (!stop || rocks.has(p) || sands.has(p) || y === (depth + 1)) {
          continue;
        }
        x += dx;
        y += 1;
        stop = false;
      }
    }
    sands.add(`${x},${y}`);
  }
  return sands.size;
}

console.log(`Part 2 : ${part2(input)}`);
