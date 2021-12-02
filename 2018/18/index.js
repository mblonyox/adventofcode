const readInput = require('../lib/readInput');
const { mapCount, flatMap } = require('../lib/array');

(async() => {
  const input = await readInput();
  let grid = input.split('\n').map(string => string.split(''));

  const getAdjacents = ([x,y]) => {
    const adjacents = [];
    for (let i = -1; i <= 1 ; i++) {
      for (let j = -1; j <= 1 ; j++) {
        if(!i && !j) continue;
        adjacents.push(grid[y+i] && grid[y+i][x+j] || null);
      }
    }
    return adjacents;
  }

  const histories = [];
  let loopFrom = null;
  let loopMod = null;

  for (let minute = 1; minute <= 1000 ; minute++) {
    histories.push(JSON.stringify(grid));
    grid = grid.map((row, y) => row.map((acre, x) => {
      const adj = mapCount(getAdjacents([x,y]));
      switch (acre) {
        case '.':
          if(adj['|'] >= 3) return '|';
          break;
        case '|':
          if(adj['#'] >= 3) return '#';
          break;
        case '#':
          if(!(adj['#'] > 0 && adj['|'] > 0)) return '.';
          break;
        default:
          break;
      }
      return acre;
    }))
    const looped = histories.indexOf(JSON.stringify(grid));
    if(~looped) {
      loopFrom = looped;
      loopMod = minute - loopFrom;
      break;
    };
  }

  const getGridAtMinute = (minute) => JSON.parse(histories[minute] || histories[loopFrom + (minute-loopFrom) % loopMod]);

  const printGrid = (grid) => {
    console.log(grid.map(row => row.join('')).join('\n'));
    console.log('\n\n');
  }

  const getResourceValue = (grid) => {
    const result = mapCount(flatMap(grid));
    return result['|'] * result['#'];
  }

  // Part 1
  const grid1 = getGridAtMinute(10);
  console.log('Part 1 : ' + getResourceValue(grid1));

  // Part 2
  const grid2 = getGridAtMinute(1000000000);
  console.log('Part 2 : ' + getResourceValue(grid2));

})();
