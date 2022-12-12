const input = await Deno.readTextFile("input.txt");

const rounds = input.trim().split("\n");

const roundOutcome = (r: string) => {
  switch (r) {
    case "A Y":
    case "B Z":
    case "C X":
      return 6;
    case "A X":
    case "B Y":
    case "C Z":
      return 3;
    case "A Z":
    case "B X":
    case "C Y":
      return 0;
    default:
      return null;
  }
};

const shapeScore = (r: string) => {
  switch (r[2]) {
    case "X":
      return 1;
    case "Y":
      return 2;
    case "Z":
      return 3;
    default:
      return null;
  }
};

const part1 = rounds.map(r => shapeScore(r)! + roundOutcome(r)!).reduce((t, x) => t + x, 0)

console.log(`Part 1: ${part1}`)

const replaced = rounds.map(r => {
  switch (r[2]) {
    case 'X':
      if (r[0] == 'A') return 'A Z'
      if (r[0] == 'C') return 'C Y'
      return r
    case 'Y':
      if (r[0] == 'A') return 'A X'
      if (r[0] == 'C') return 'C Z'
      return r
    case 'Z':
      if (r[0] == 'A') return 'A Y'
      if (r[0] == 'C') return 'C X'
      return r
    default:
      return r
  }
})

const part2 = replaced.map(r => shapeScore(r)! + roundOutcome(r)!).reduce((t, x) => t + x, 0)

console.log(`Part 2: ${part2}`)
