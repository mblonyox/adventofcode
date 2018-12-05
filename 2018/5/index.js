const {promisify} = require('util');
const fs = require('fs');
const path = require('path');

const readFile = promisify(fs.readFile);
const inputFile = path.resolve(__dirname + '/input.txt');

const matchPattern = "aA|bB|cC|dD|eE|fF|gG|hH|iI|jJ|kK|lL|mM|nN|oO|pP|qQ|rR|sS|tT|uU|vV|wW|xX|yY|zZ|Aa|Bb|Cc|Dd|Ee|Ff|Gg|Hh|Ii|Jj|Kk|Ll|Mm|Nn|Oo|Pp|Qq|Rr|Ss|Tt|Uu|Vv|Ww|Xx|Yy|Zz"
const matchRegex = new RegExp(matchPattern, 'g');

const getShortestPolymer = (string) => {
  isDone = false;
  result = string;

  while(!isDone) {
    const before = result;
    result = result.replace(matchRegex, '');
    if(before === result) isDone = true;
  }

  return result;
}

(async () => {
  const inputText = await readFile(inputFile, { encoding: 'UTF-8'});
  const result = getShortestPolymer(inputText.replace('\n', ''));

  console.log('Part 1 : ' + result.length);

  part2 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
    .reduce((smallest, char) => {
      current = getShortestPolymer(result.replace(new RegExp(char, 'gi'), ''))
      smallest = Math.min(current.length, smallest);
      return smallest
    }, result.length);

  console.log('Part 2 : ' + part2);
})();