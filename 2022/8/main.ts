const input = await Deno.readTextFile("input.txt");

const grid = input.trim().split("\n").map((l) =>
  l.split("").map((n) => parseInt(n))
);
const grid_rows = grid.length;
const grid_cols = grid[0].length;

let part1 = 0;

for (let i = 0; i < grid_rows; i++) {
  for (let j = 0; j < grid_cols; j++) {
    const x = grid[i][j];

    const up = !grid.map((x) => x[j]).slice(0, i).some((y) => y >= x);
    const left = !grid[i].slice(0, j).some((y) => y >= x);
    const down = !grid.map((x) => x[j]).slice(i + 1).some((y) => y >= x);
    const right = !grid[i].slice(j + 1).some((y) => y >= x);

    if (up || left || down || right) part1++;
  }
}

console.log(`Part 1: ${part1}`);

let part2 = 0;

for (let i = 0; i < grid_rows; i++) {
  for (let j = 0; j < grid_cols; j++) {
    const x = grid[i][j];

    const reducer = (
      state: { isBlocked: boolean; trees: number },
      tree: number,
    ) => {
      if (state.isBlocked) return state;
      if (tree <= x) state.trees += 1;
      if (tree == x) state.isBlocked = true;
      return state;
    };

    const up = grid.map((x) => x[j]).slice(0, i).reduceRight(reducer, {
      isBlocked: false,
      trees: 0,
    }).trees;
    const left = grid[i].slice(0, j).reduceRight(reducer, {
      isBlocked: false,
      trees: 0,
    }).trees;
    const down = grid.map((x) => x[j]).slice(i + 1).reduce(reducer, {
      isBlocked: false,
      trees: 0,
    }).trees;
    const right = grid[i].slice(j + 1).reduce(reducer, {
      isBlocked: false,
      trees: 0,
    }).trees;

    const scenic_score = up * left * down * right;

    part2 = Math.max(part2, scenic_score);
  }
}

console.log(`Part 2: ${part2}`);
