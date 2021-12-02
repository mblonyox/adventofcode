const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput();

  const setup = (input) => {
    const map = input.split('\n').map(row => row.split(''));
    const carts = [];
    const tracks = {};
    for (let i = 0; i < map.length; i++) {
      for (let j = 0; j < map[i].length; j++) {
        const char = map[i][j];
        if(['^','v','<','>'].includes(char)) {
          const direction = {
            '^':[-1,0],
            'v':[1,0],
            '<':[0,-1],
            '>':[0,1]
          }[char]
          carts.push(new Cart([i,j], direction));
        } else if(['\\','/','+'].includes(char)) {
          tracks[[i,j]] = char;
        }
      }
    }
    return {carts, tracks}
  }

  // Part 1
  const {carts: carts1, tracks: tracks1} = setup(input);
  let crash = null;
  while(!crash) {
    carts1.sort((a,b) => a.position[0] === b.position[0] ? a.position[1] - b.position[1] : a.position[0] - b.position[0])
    for (let i = 0; i < carts1.length; i++) {
      const cart = carts1[i];
      const newPos = [cart.position[0] + cart.direction[0], cart.position[1] + cart.direction[1]]
      if(~carts1.findIndex((cart) => cart.position.toString() === newPos.toString())) {
        crash = newPos.reverse().toString();
        break;
      } else {
        cart.position = newPos;
        cart.turn(tracks1[newPos]);
      }
    }
  }
  console.log('Part 1 : ' + crash)

  // Part 2
  let {carts: carts2, tracks: tracks2} = setup(input);
  let tick = 0;
  while(carts2.length > 1) {
    carts2.sort((a,b) => a.position[0] === b.position[0] ? a.position[1] - b.position[1] : a.position[0] - b.position[0])
    for (let i = 0; i < carts2.length; i++) {
      const cart = carts2[i];
      const newPos = [cart.position[0] + cart.direction[0], cart.position[1] + cart.direction[1]];
      if(~carts2.findIndex((cart) => cart.position.toString() === newPos.toString())) {
        const cart2 = carts2.find((cart) => cart.position.toString() === newPos.toString());
        cart.crashed = true;
        cart.position = newPos;
        cart2.crashed = true;
      } else if(!cart.crashed){
        cart.position = newPos;
        cart.turn(tracks2[newPos]);
      }
    }
    carts2 = carts2.filter(cart => !cart.crashed);
    // console.log('Tick ' + tick++);
    // console.log(carts2)
  }
  console.log('Part 2 : ' + carts2[0].position.reverse())
})().catch(err => console.log(err));

class Cart {
  constructor(position, direction) {
    this.position = position;
    this.direction = direction;
    this.intrsctnMod = 0;
    this.crashed = false;
  }

  turn(track) {
    if(track === '+') {
      if(this.intrsctnMod === 0) {
        if(this.direction[0]) this.direction = [this.direction[1], this.direction[0]]
        else this.direction = [-this.direction[1], -this.direction[0]]
      } else if(this.intrsctnMod === 2) {
        if(this.direction[1]) this.direction = [this.direction[1], this.direction[0]]
        else this.direction = [-this.direction[1], -this.direction[0]]
      }
      this.intrsctnMod = (this.intrsctnMod + 1)%3
    } else if(track === '\\') {
      this.direction = [this.direction[1], this.direction[0]]
    } else if(track === '/'){
      this.direction = [-this.direction[1], -this.direction[0]]
    }
  }
}
