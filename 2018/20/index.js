const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput();
  const directions = {
    'N': [0,-1],
    'E': [1,0],
    'S': [0,1],
    'W': [-1,0]
  }
  const branches = [];
  const distances = {};
  const current = [0,0]
  const previous = current.slice();
  for (const char of input.slice(1,-1)) {
    switch (char) {
      case '(':
        branches.push(current.slice());
        break;
      case ')':
        branches.pop();
        break;
      case '|':
        const [x,y] = branches[branches.length-1];
        current[0] = x;
        current[1] = y;
        break;
      default:
        const [dx, dy] = directions[char];
        current[0] += dx;
        current[1] += dy;
        distances[current] = Math.min(distances[current] || Infinity, (distances[previous] || 0) +1);
        break;
    }
    const [px, py] = current;
    previous[0] = px;
    previous[1] = py;
  }

  console.log('Part 1 : ' + Math.max(...Object.values(distances)));
  console.log('Part 2 : ' + Object.values(distances).filter(x => x >= 1000).length);
})();
