const input = await Deno.readTextFile("input.txt");

const [input1, input2] = input.trim().split("\n\n");

const stacks: { [index: string]: string[] } = {};

const [indexes, ...crates] = input1.split("\n").reverse();

indexes.match(/\w+/g)?.forEach((i) => {
  const j = indexes.indexOf(i);
  stacks[i] = crates.map((c) => c.charAt(j)).filter((x) => x.trim());
});

interface IProcedure {
  move: number;
  from: string;
  to: string;
}

const procedures: IProcedure[] = input2.split("\n").map((l) => {
  const res = l.match(/move (\d+) from (\d+) to (\d+)/)!;
  return {
    move: parseInt(res[1]),
    from: res[2],
    to: res[3],
  };
});

const stacks1 = JSON.parse(JSON.stringify(stacks)) as {
  [index: string]: string[];
};

for (const proc of procedures) {
  for (let i = 0; i < proc.move; i++) {
    const crate = stacks1[proc.from].pop();
    if (crate) stacks1[proc.to].push(crate);
  }
}

const part1 = Object.keys(stacks1).sort().reduce(
  (t, k) => t + stacks1[k].at(-1),
  "",
);

console.log(`Part 1: ${part1}`);

const stacks2 = JSON.parse(JSON.stringify(stacks)) as {
  [index: string]: string[];
};

for (const proc of procedures) {
  const crates = stacks2[proc.from].splice(-proc.move);
  stacks2[proc.to].splice(Infinity, 0, ...crates);
}

const part2 = Object.keys(stacks2).sort().reduce(
  (t, k) => t + stacks2[k].at(-1),
  "",
);

console.log(`Part 2: ${part2}`);
