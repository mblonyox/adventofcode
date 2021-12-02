const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput();
  const points = input.split('\n').map(point => point.split(',').map(d => parseInt(d)));

  const constellations = [];
  while(points.length) {
    const constellation = []
    const queue = [points.shift()]
    while(queue.length) {
      const current = queue.shift();
      const nearPoints = points.filter(point => getDistance(current, point) <= 3);
      for (const point of nearPoints) {
        const index = points.indexOf(point);
        queue.push(points.splice(index,1)[0]);
      }
      constellation.push(current);
    }
    constellations.push(constellation);
  }

  console.log('Final part : ' + constellations.length);
})();

const getDistance = (from, to) => {
  const [a,b,c,d] = from;
  const [w,x,y,z] = to;
  return Math.abs(a-w) +
    Math.abs(b-x) +
    Math.abs(c-y) +
    Math.abs(d-z)
}
