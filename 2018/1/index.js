const {promisify} = require('util');
const fs = require('fs');

const readFile = promisify(fs.readFile);


(async () => {
  input = await readFile('input.txt', {encoding: 'utf-8'});
  inputArray = input.split('\n');
  console.log('Part 1 : ' + eval(input));

  result = [];
  current = 0;
  index = 0;
  while(!~result.indexOf(current)) {
    result.push(current);
    current += parseInt(inputArray[index])
    index++
    if(index >= inputArray.length) index = 0;
  }
  console.log('Part 2 : ' + current);
})();