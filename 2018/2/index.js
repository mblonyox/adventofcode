const {promisify} = require('util');
const fs = require('fs');
const path = require('path');

const readFile = promisify(fs.readFile);
const inputFile = path.resolve(__dirname + '/input.txt')

function mapCount(arr) {
  result = {};
  arr.forEach(el => {
    result[el] = (result[el] || 0) + 1;
  });
  return result;
}

function sameChar(str1, str2) {
  arr1 = str1.split('')
  arr2 = str2.split('')

  return arr1.filter((v, i) => v === arr2[i]).join('')
}

(async () => {
  inputText = await readFile(inputFile, {encoding: 'utf-8'});
  inputArray = inputText.split('\n');

  // Part 1
  twoLetters = 0;
  threeLetters = 0;
  for (let i = 0; i < inputArray.length; i++) {
    mapped = mapCount(inputArray[i].split(''));
    values = Object.values(mapped);
    if(~values.indexOf(2)) twoLetters++;
    if(~values.indexOf(3)) threeLetters++;
  }
  console.log('Part 1 : ' + twoLetters * threeLetters);

  // Part 2
  result = inputArray.reduce((t, v, i) => {
    for (let index = i+1; index < inputArray.length; index++) {
      temp = sameChar(v, inputArray[index]);
      if(temp.length > t.length) t = temp;
    }
    return t
  },'')
  console.log('Part 2 : ' + result);
})();