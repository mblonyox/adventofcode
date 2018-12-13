const readInput = require('../../lib/readInput');

(async() => {
  const input = await readInput();
  const map = input.split('\n').map(row => row.split(''));

  const carts = [];
  for (let i = 0; i < map.length; i++) {
    for (let j = 0; j < map[i].length; j++) {
      const str = map[i][j];
      const char = chars[str];
      if(!char) map[i][j] = null
      else {
        const road = new Road(j, i, char.tipe, str);
        if(char.tipe === 'cart') {
          const cart = new Cart(road, char.direction);
          road.cart = cart;
          carts.push(cart);
        }
        if(map[i-1] && map[i-1][j]) {
          map[i-1][j].s = road;
          road.n = map[i-1][j];
        }
        if(map[i][j-1]) {
          map[i][j-1].e = road;
          road.w = map[i][j-1];
        }
        map[i][j] = road;
      }
    }
  }
  // console.log(carts);
  while(true) {
    map.forEach(row => row.forEach(road => {
      if(road && road.cart) road.cart.move();
    }))
  }
})().catch(err => console.log(err.message));

const directions = {
  'n': {left: 'w', right: 'e'},
  'e': {left: 'n', right: 's'},
  's': {left: 'e', right: 'w'},
  'w': {left: 's', right: 'n'}
};

const chars = {
  '^': {tipe: 'cart', direction: 'n'},
  '>': {tipe: 'cart', direction: 'e'},
  'v': {tipe: 'cart', direction: 's'},
  '<': {tipe: 'cart', direction: 'w'},
  '|': {tipe: 'road', },
  '-': {tipe: 'road', },
  '/': {tipe: 'curve',},
  '\\': {tipe: 'curve'},
  '+': {tipe: 'intersection'}
}

class Road {
  constructor(x,y, tipe, char) {
    this.x = x;
    this.y = y;
    this.tipe = tipe;
    this.char = char;
    // Connected road
    this.n = null;
    this.e = null;
    this.s = null;
    this.w = null;
  }
}

class Cart {
  constructor(road, direction) {
    this.road = road;
    this.direction = direction;
    this.turnCounter = 0;
  }

  move() {
    const nextRoad = this.road[this.direction]
    if(nextRoad.cart) throw(new Error(`Collision on road: ${nextRoad.x},${nextRoad.y}`));
    this.road.cart = null;
    this.road = nextRoad;
    this.road.cart = this;
    switch(this.road.tipe) {
      case 'intersection':
        if(this.turnCounter%3 === 0) this.turn(true)
        else if(this.turnCounter%3 === 2) this.turn(false);
        this.turnCounter++;
        break;
      case 'curve':
        if ((this.road.char === '/' && this.direction === 'e') ||
          (this.road.char === '\\' && this.direction === 's')) {
            this.turn(true);
          } else {
            this.turn(false);
          }
        break;
      default:
        break;
    }
  }

  turn(toLeft) {
    this.direction = toLeft ? directions[this.direction].left : directions[this.direction].right;
  }
}
