const {promisify} = require('util');
const fs = require('fs');
const path = require('path');

const readFile = promisify(fs.readFile);

async function readInput(file = 'input.txt') {
  const inputFile = path.resolve(path.dirname(require.main.filename) , file);
  const input = await readFile(inputFile, {encoding: 'UTF-8'});
  return input.trim();
}

module.exports = readInput;
