const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput();
  const bots = input.split('\n').map(string => {
    const {groups: {p, r}} = string.match(/pos=<(?<p>[\d\,-]+)>, r=(?<r>\d+)/);
    return {pos: p.split(',').map(d => parseInt(d)), r: parseInt(r)};
  })

  const botsInRange = (base, r) => bots.filter(bot => {
    const dist = getDistance(base, bot.pos);
    return dist <= (r || bot.r);
  }).length;

  // Part 1
  const largest = bots.reduce((prev, curr) => prev.r >= curr.r ? prev : curr);
  console.log('Part 1 : ' + botsInRange(largest.pos, largest.r));

  // Part 2

  const minX = Math.min(...bots.map(bot => bot.pos[0]));
  const maxX = Math.max(...bots.map(bot => bot.pos[0]));
  const minY = Math.min(...bots.map(bot => bot.pos[1]));
  const maxY = Math.max(...bots.map(bot => bot.pos[1]));
  const minZ = Math.min(...bots.map(bot => bot.pos[2]));
  const maxZ = Math.max(...bots.map(bot => bot.pos[2]));

  const min = [minX, minY, minZ];
  const max = [maxX, maxY, maxZ];

  const search = function*() {
    let best = null;
    while (true) {
      let scale = 10**7;
      while(scale>=1) {
        const start = best ? [best[0] - 10*scale, best[1] - 10*scale, best[2] - 10*scale] : min;
        const end = best ? [best[0] + 10*scale, best[1] + 10*scale, best[2] + 10*scale] : max;

        best = Array.from(iterate(start, end, scale)).sort(
          (a, b) => botsInRange(b) - botsInRange(a) || getDistance(a) - getDistance(b)
        ).shift();

        scale /= 10;
      }
      yield best;
    }
  }

  const bests = search();

  let prevResult = getDistance(bests.next().value);
  let nextResult = getDistance(bests.next().value);

  while(nextResult !== prevResult) {
    prevResult = nextResult;
    nextResult = getDistance(bests.next().value);
  }
  console.log('Part 2 : ' + nextResult);

})();

const getDistance = (from, to = [0, 0, 0]) => {
  const [x, y, z] = to;
  const [bx, by, bz] = from;
  return Math.abs(x-bx) +
    Math.abs(y-by) +
    Math.abs(z-bz);
}

const iterate = function*(start, end, scale) {
  const [ax, ay, az] = start;
  const [bx, by, bz] = end;
  for (let x = ax; x < bx; x+= scale) {
    for (let y = ay; y < by; y+= scale) {
      for (let z = az; z < bz; z+= scale) {
        yield [x, y, z];
      }
    }
  }
}
