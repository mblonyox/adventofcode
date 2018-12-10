const readInput = require('../../lib/readInput');
const { create2dArray, flatMap } = require('../../lib/array');

(async() => {
  const input = await readInput();
  const stars = input.split('\n').map(string => {
    const x = parseInt(string.substring(10, 16));
    const y = parseInt(string.substring(18, 24));
    const vx = parseInt(string.substring(36, 38));
    const vy = parseInt(string.substring(40, 42));
    return [x, y, vx, vy]
  });
  const space = new Space(stars);
  let lastDistance;
  let result;
  do {
    if(space.distance() < 100) result = space.print();
    lastDistance = space.distance();
    space.lapse();
  } while (space.distance() < lastDistance);
  console.log(result);
})();

class Star {
  constructor(x, y, vx, vy) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
  }

  move() {
    this.x += this.vx;
    this.y += this.vy;
  }
}

class Space {
  constructor(stars) {
    this.stars = stars.map(star => new Star(...star))
    this.time = 0;
  }

  lapse() {
    this.stars.forEach(star => {
      star.move();
    });
    this.time++
  }

  distance() {
    const anchor = this.anchor();
    return Math.max(anchor.w, anchor.h)
  }

  anchor() {
    const xArray = this.stars.map(star => star.x);
    const yArray = this.stars.map(star => star.y);
    const x = Math.min(...xArray);
    const y = Math.min(...yArray);
    const w = Math.max(...xArray) - x;
    const h = Math.max(...yArray) - y;
    return {x, y, w, h};
  }

  print() {
    const anchor = this.anchor();
    const area = create2dArray(anchor.h+1, anchor.w+1, ' ');
    this.stars.forEach(star => {
      area[star.y - anchor.y][star.x - anchor.x] = '#'
    })
    let result = 'Part 1 : \r\n' +
      area.map(row => row.join('')).join('\r\n') + '\r\n\r\n';

    result += `Part 2 : ${this.time}`;
    return result;
  }
}