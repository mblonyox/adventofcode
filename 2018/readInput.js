const {promisify} = require('util');
const fs = require('fs');
const path = require('path');

const readFile = promisify(fs.readFile);

async function readInput() {
  const inputFile = path.resolve(path.dirname(require.main.filename) , 'input.txt');
  const input = await readFile(inputFile, {encoding: 'UTF-8'});
  return input.trim();
}

module.exports = readInput;
