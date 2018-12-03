const {promisify} = require('util');
const fs = require('fs');
const path = require('path');

const readFile = promisify(fs.readFile);
const inputFile = path.resolve(__dirname + '/input.txt');

(async () => {
  inputText = await readFile(inputFile, { encoding: 'UTF-8'});
  inputArray = inputText.split('\n').map((str) => {
    const [, id, x, y, w, h] = /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/.exec(str).map(x => parseInt(x, 10))
    return {id, x, y, w, h}
  });
  fabric = new Array(1000).fill(0).map(_ => new Array(1000).fill(0));
  inputArray.forEach(claim => {
    claim.overlap = false
    const {id, x, y, w, h} = claim
    for (let i = 0; i < h; i++) {
      for (let j = 0; j < w; j++) {
        cell = fabric[y+i][x+j]
        if(cell) {
          if(cell !== 'X') inputArray.find(x => x.id === cell).overlap = true
          claim.overlap = true
          fabric[y+i][x+j] = 'X'
        } else {
          fabric[y+i][x+j] = id
        }
      }
    }
  });
  console.log('Part 1 : ' + fabric.reduce((acc, x) => acc.concat(x), []).filter(x => x === 'X').length)
  console.log('Part 2 : ' + inputArray.filter(claim => !claim.overlap)[0].id)
})();