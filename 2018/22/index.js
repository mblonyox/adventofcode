const readInput = require('../lib/readInput');
const { create2dArray, flatMap, arraySum } = require('../lib/array');

(async() => {
  const input = await readInput();
  const {groups: {d, t}} = input.match(/depth: (?<d>\d+)\ntarget: (?<t>\d+\,\d+)/);
  const depth = parseInt(d);
  const target = t.split(',').map(d => parseInt(d));
  const [row, col] = target;
  const grid = create2dArray(col+100, row+100, null);

  for (let i = 0; i < grid.length; i++) {
    for (let j = 0; j < grid[i].length; j++) {
      const above = grid[i-1] && grid[i-1][j] || null;
      const left = grid[i][j-1] || null;
      const isTarget = i === col && j === row;
      grid[i][j] = new Region([j,i], above, left, depth, isTarget);
    }
  }
  const part1 = grid.slice(0, col+1).map(val => val.slice(0, row+1))
  console.log('Part 1 : ' + arraySum(flatMap(part1).map(r => r.riskLevel)));

  const distances = {};
  const queue = [{dist: 0, pos: [0,0], equip: 1}];
  const destKey = JSON.stringify({pos: target, equip: 1});
  const directions = [
    [0,-1],
    [1,0],
    [-1,0],
    [0,1]
  ];
  while(queue.length) {
    const {dist, pos, equip} = queue.shift();
    const key = JSON.stringify({pos, equip});
    // Skip if path is took longer.
    if(distances[key] && distances[key] <= dist) continue;
    // Skip if time to target have been found and current is longer.
    if(distances[destKey] && distances[destKey] <= dist) continue;
    distances[key] = dist;
    const [x, y] = pos;
    // Changing to possible gear
    for (let i = 0; i < 3; i++) {
      if(i !== equip && i !== grid[y][x].riskLevel) queue.push({dist: dist+7, pos, equip: i});
    }
    // Move to all possible directions
    for (const direction of directions) {
      const [dx, dy] = direction;
      const newX = x+dx;
      const newY = y+dy;
      if(newX < 0 ||
         newY < 0 ||
         !grid[newY] ||
         !grid[newY][newX] ||
         grid[newY][newX].riskLevel === equip) continue;
      queue.push({dist: dist+1, pos: [newX, newY], equip});
    }
  }
  console.log('Part 2 : ' + distances[destKey]);
})();

class Region {
  constructor([x,y], above, left, depth, isTarget = false) {
    this.x = x;
    this.y = y;
    this.geoIndex = this.constructor.calcGeoIndex(x, y, above, left, isTarget);
    this.erosionLevel = (this.geoIndex + depth) % 20183;
  }

  static calcGeoIndex(x, y, above, left, isTarget) {
    if(isTarget) return 0;
    if(x === 0 && y === 0) return 0;
    if(x === 0) return y * 48271;
    if(y === 0) return x * 16807;
    return above.erosionLevel * left.erosionLevel;
  }

  get riskLevel() {
    return this.erosionLevel % 3;
  }

  get typeString() {
    return ['rocky', 'wet', 'narrow'][this.riskLevel];
  }

  get typeChar() {
    return ['.', '=', '|'][this.riskLevel];
  }
}