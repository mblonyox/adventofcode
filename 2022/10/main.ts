const input = await Deno.readTextFile("input.txt");

const program = input.trim().split("\n");

function part1(program: string[]): number {
  const xHistory = [1];

  program.forEach((instruction) => {
    if (instruction.startsWith("noop")) xHistory.push(xHistory.at(-1)!);
    if (instruction.startsWith("addx")) {
      const last = xHistory.at(-1)!;
      const value = parseInt(instruction.substring(5));
      xHistory.push(last);
      xHistory.push(last + value);
    }
  });

  return (20 * xHistory[20 - 1]) + (60 * xHistory[60 - 1]) +
    (100 * xHistory[100 - 1]) +
    (140 * xHistory[140 - 1]) + (180 * xHistory[180 - 1]) +
    (220 * xHistory[220 - 1]);
}

console.log(`Part 1: ${part1(program)}`);

function part2(program: string[]): string {
  let result = "";
  let cycle = 0;
  let xRegister = 1;

  program.forEach((instruction) => {
    if (instruction.startsWith("noop")) {
      result += Math.abs(xRegister - (cycle % 40)) <= 1 ? "█" : " ";
      cycle++;
    }
    if (instruction.startsWith("addx")) {
      result += Math.abs(xRegister - (cycle % 40)) <= 1 ? "█" : " ";
      cycle++;
      result += Math.abs(xRegister - (cycle % 40)) <= 1 ? "█" : " ";
      cycle++;
      xRegister += parseInt(instruction.substring(5));
    }
  });

  return result.match(/.{1,40}/g)!.join("\n");
}

console.log(`Part 2: \n${part2(program)}`);
