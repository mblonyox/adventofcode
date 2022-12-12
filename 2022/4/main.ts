const input = await Deno.readTextFile("input.txt");

const assignments = input.trim().split("\n").map((l) => l.split(",")).map((
  [s1, s2],
) => [
  s1.split("-").map((x) => parseInt(x)),
  s2.split("-").map((x) => parseInt(x)),
]);

const part1 = assignments.filter(([s1, s2]) => {
  if (s1[0] <= s2[0] && s1[1] >= s2[1]) return true;
  if (s2[0] <= s1[0] && s2[1] >= s1[1]) return true;
  return false;
}).length;

console.log(`Part 1 : ${part1}`);

const part2 = assignments.filter(([s1, s2]) => {
  if (s1[0] <= s2[0] && s1[1] >= s2[0]) return true;
  if (s2[0] <= s1[0] && s2[1] >= s1[0]) return true;
  return false;
}).length;

console.log(`Part 2 : ${part2}`);
