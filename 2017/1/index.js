const readInput = require('../../lib/readInput');

const part1 = (input) => {
  return input.split('').reduce((t,v,i) => {
    t += (input[i+1] || input[0]) === v ? parseInt(v) : 0;
    return t;
  },0)
}

const part2 = (input) => {
  return input.split('').reduce((t,v,i) => {
    t += (input[(input.length/2+i) % input.length]) === v ? parseInt(v) : 0;
    return t;
  },0)
}

const main = async() => {
  const input = await readInput();
  console.log('Part 1 : ' + part1(input));
  console.log('Part 2 : ' + part2(input));
};

if(require.main === module) main();

module.exports = {
  part1,
  part2,
}
