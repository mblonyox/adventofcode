const readInput = require('../lib/readInput');
const { create2dArray, flatMap, arraySum } = require('../lib/array');

(async() => {
  const input = await readInput();
  const serial = parseInt(input);
  const cellArray = create2dArray(300, 300, null);
  for (let i = 0; i < 300; i++) {
    for (let j = 0; j < 300; j++) {
      cellArray[i][j] = new Cell(j+1, i+1, serial, cellArray);
    }
  }
  const cells = flatMap(cellArray);
  const getMaxGridCell = (size) => {
    const cell = cells.reduce((result, current) => {
      if(current.gridPower(size) !== null && current.gridPower(size) > result.gridPower(size)) return current;
      return result;
    })
    const value = cell.gridPower(size);
    return {x: cell.x, y:cell.y, value};
  }

  // Part 1
  const maxGridCell = getMaxGridCell(3)
  console.log('Part 1 : ' + maxGridCell.x +','+ maxGridCell.y);

  // Part 2
  const maxGrid2 = (new Array(10)).fill(null).reduce((result, v, index) => {
    index = index+10;
    current = getMaxGridCell(index);
    if(current.value > result.value) return {...current, index};
    return result;
  }, {value: 0});
  console.log('Part 2 : ' + maxGrid2.x +','+ maxGrid2.y +','+ maxGrid2.index);
})();

class Cell {
  constructor(x, y, serial, matrix) {
    this.x = x;
    this.y = y;
    this.powerLevel = this._powerLevel(x, y, serial);
    this.matrix = matrix;
  }

  _powerLevel(x, y, serial) {
    const rackId = x + 10;
    const level = rackId * (rackId * y + serial);
    return (level/100 | 0)%10 - 5;
  }

  gridPower(size) {
    const x = this.x - 1;
    const y = this.y - 1;
    if(x + size <= 300 && y + size <= 300) {
      let result = 0;
      for (let i = 0; i < size; i++) {
        for (let j = 0; j < size; j++) {
          result += this.matrix[y+i][x+j].powerLevel;
        }
      }
      return result;
    }
    return null;
  }
}
