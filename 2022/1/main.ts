const input = await Deno.readTextFile("input.txt")

const elves = input.trim().split("\n\n").map(el => el.split("\n").map(n => parseInt(n)))

const calories =  elves.map(x => x.reduce((a, b) => a + b, 0)).sort()

console.log(`Part 1: ${calories.at(-1)}` )
console.log(`Part 2: ${calories.at(-1)! + calories.at(-2)! + calories.at(-3)!}`)