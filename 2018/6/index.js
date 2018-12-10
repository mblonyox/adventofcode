const readInput = require('../../lib/readInput');
const { create2dArray, arraySet, flatMap, mapCount } = require('../../lib/array');

const nearestCoordinate = (src, points) => {
  const allDistances = points.map(([x, y]) => Math.abs(src.y - y) + Math.abs(src.x -x));
  const shortest = Math.min(...allDistances);
  const filtered = allDistances.filter(x => x === shortest);
  if(filtered.length > 1) return '.';
  return allDistances.findIndex(x => x===shortest);
}

(async () => {
  const input = await readInput();
  const points = input.split('\n').map(point => point.split(', '));
  const maxRow = Math.max(...points.map(p => p[0]));
  const maxCol = Math.max(...points.map(p => p[1]));
  const map = create2dArray(maxCol, maxRow, null);
  for (let i = 0; i < maxCol; i++) {
    for (let j = 0; j < maxRow; j++) {
      map[i][j] = nearestCoordinate({x: j, y: i}, points);
    }
  }

  allMap = flatMap(map);
  countedMap = mapCount(allMap);

  edges = [
    ...map[0],
    ...map[map.length-1],
    ...map.map(row => row[0]),
    ...map.map(row => row[row.length-1])
  ]
  edges = arraySet(edges);
  console.log('Part 1 : ' + Object.entries(countedMap).filter(([x]) => !edges.includes(x*1)).sort((a,b) => b[1] - a[1])[0][1]);
  for (let i = 0; i < maxCol; i++) {
    for (let j = 0; j < maxRow; j++) {
      distance = points.map(([x, y]) => Math.abs(i - y) + Math.abs(j - x)).reduce((t,v) => t+v);
      map[i][j] = distance < 10000 ? '#' : '.'
    }
  }
  allMap = flatMap(map);
  countedMap = mapCount(allMap);

  console.log('Part 2 : ' + countedMap['#']);
})();