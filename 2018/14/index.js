let input = process.argv[2];
if(!input || isNaN(parseInt(input))) {
  console.error('Invalid input: must be integer.');
  process.exit(1);
}
input = parseInt(input);

let recipes = [3,7];
let elf1i = 0;
let elf2i = 1;

let inputLength = input.toString().length;
let lastRecipes = '.'.repeat(inputLength);

while(!~lastRecipes.indexOf(`${input}`) || recipes.length < input+10) {
  lastRecipes = lastRecipes.substr(1-inputLength)
  const recipe1 = recipes[elf1i];
  const recipe2 = recipes[elf2i];
  const newRecipe = recipe1+recipe2;
  if (newRecipe > 9) recipes.push(1);
  recipes.push(newRecipe%10);
  lastRecipes += newRecipe
  elf1i = (elf1i + recipe1 + 1) % recipes.length;
  elf2i = (elf2i + recipe2 + 1) % recipes.length;
}

console.log('Part 1: '+recipes.join('').substr(input, 10))
console.log('Part 2: '+recipes.join('').indexOf(`${input}`));
