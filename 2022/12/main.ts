import graphlib from "https://esm.sh/@dagrejs/graphlib@2.1.4";

const input = await Deno.readTextFile("input.txt");

const grid = input.trim().split("\n").map((l) => l.split(""));

interface Position {
  x: number;
  y: number;
}

function posToStr(pos: Position): string {
  return `${pos.x},${pos.y}`;
}

const { start, end } = (() => {
  let start: Position = { x: 0, y: 0 };
  let end: Position = { x: 0, y: 0 };
  for (let y = 0; y < grid.length; y++) {
    const row = grid[y];
    for (let x = 0; x < row.length; x++) {
      const point = row[x];
      if (point == "S") start = { x, y };
      if (point == "E") end = { x, y };
    }
  }
  return { start, end };
})();

const heightmap = grid.map((row) =>
  row.map((s) => {
    switch (s) {
      case "S":
        return 0;
      case "E":
        return 25;
      default:
        return s.charCodeAt(0) - 97;
    }
  })
);

function part1(): number {
  const graph = new graphlib.Graph();
  for (let y = 0; y < heightmap.length; y++) {
    const maxY = heightmap.length - 1;
    const row = heightmap[y];
    for (let x = 0; x < row.length; x++) {
      const curr = { x, y };
      const maxX = row.length - 1;
      const point = row[x];
      const isClimbable = (pos: Position) => {
        const point2 = heightmap[pos.y][pos.x];
        return (point2 - point) <= 1;
      };
      const check = (pos: Position) => {
        if (
          pos.x >= 0 &&
          pos.x <= maxX &&
          pos.y >= 0 &&
          pos.y <= maxY &&
          isClimbable(pos)
        ) {
          graph.setEdge(posToStr(curr), posToStr(pos));
        }
      };
      check({ x: x - 1, y });
      check({ x: x + 1, y });
      check({ x, y: y - 1 });
      check({ x, y: y + 1 });
    }
  }
  const paths = graphlib.alg.dijkstra(graph, posToStr(start));
  return paths[posToStr(end)].distance;
}

console.log(`Part 1: ${part1()}`);

function part2(): number {
  const graph = new graphlib.Graph();
  for (let y = 0; y < heightmap.length; y++) {
    const maxY = heightmap.length - 1;
    const row = heightmap[y];
    for (let x = 0; x < row.length; x++) {
      const curr = { x, y };
      const maxX = row.length - 1;
      const point = row[x];
      const isFallable = (pos: Position) => {
        const point2 = heightmap[pos.y][pos.x];
        return (point2 - point) >= -1;
      };
      const check = (pos: Position) => {
        if (
          pos.x >= 0 &&
          pos.x <= maxX &&
          pos.y >= 0 &&
          pos.y <= maxY &&
          isFallable(pos)
        ) {
          graph.setEdge(posToStr(curr), posToStr(pos));
        }
      };
      check({ x: x - 1, y });
      check({ x: x + 1, y });
      check({ x, y: y - 1 });
      check({ x, y: y + 1 });
    }
  }
  const paths = graphlib.alg.dijkstra(graph, posToStr(end));
  const distances = heightmap.map((row, y) =>
    row.map((point, x) => point ? null : posToStr({ x, y }))
  ).flat()
    .filter((s): s is string => s !== null)
    .map((pos) => paths[pos].distance)
    .filter((d) => d !== Infinity)
    .sort((a, b) => a - b);
  return distances[0];
}

console.log(`Part 2: ${part2()}`);
