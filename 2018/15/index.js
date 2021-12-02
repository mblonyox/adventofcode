const readInput = require('../lib/readInput');
const { arraySum, arraySet } = require('../lib/array');

(async() => {
  const input = await readInput();
  const grid = input.split('\n').map(row => row.split(''));

  const cave1 = new Cave(grid);
  cave1.log = true;
  console.log('Part 1 : ' + cave1.play());

  const powerUp = (power) => {
    try {
      const cave = new Cave(grid, power);
      console.log('Part 2 : '+ cave.play(true));
    } catch (err) {
      console.log('Failed attempt. Increasing power');
      console.log('Power : ' + (power+1));
      powerUp(power+1);
    }
  }

  powerUp(4);
})();

class Cave {
  constructor(grid, power = 3) {
    this.log = false;
    this.grid = grid;
    this.units = [];
    this.walls = {};
    for (let i = 0; i < grid.length; i++) {
      for (let j = 0; j < grid[i].length; j++) {
        let el = grid[i][j];
        this.walls[[j,i]] = el === '#';
        if(~'EG'.indexOf(el)) this.units.push(new Unit(el, [j,i], this, el === 'E' ? power : 3))
      }
    }
  }

  play(survive = false) {
    let rounds = 0;
    while (true) {
      if(this.round(survive)) break;
      rounds++;
      if(this.log) this.print(rounds);
    }
    return (rounds) * arraySum(this.units.filter(unit => unit.alive).map(unit => unit.hp));
  }

  round(survive) {
    this.units.sort((a,b) => a.position[1] - b.position[1] || a.position[0] - b.position[0]);
    for (let i = 0; i < this.units.length; i++) {
      const unit = this.units[i];
      if(unit.turn(survive)) return true;
    }
    return false;
  }

  print(rounds) {
    const output = this.grid.map((r,i) => r.map((c,j) => {
      const unit = this.units.find(unit => unit.alive && `${unit.position}` === `${[j,i]}`);
      if(unit) return unit.team;
      return this.walls[[j,i]] ? '#' : ' ';
    }).join('')).join('\n')
    console.clear();
    console.log(`Round ${rounds} : \n`);
    console.log(output);
  }
}

class Unit {
  constructor(team, position, cave, power) {
    this.team = team;
    this.position = position;
    this.hp = 200;
    this.power = power;
    this.cave = cave;
  }

  get alive() {
    return this.hp > 0;
  }

  get adjacents() {
    return this.constructor.getAdjacents(this.position);
  }

  static getAdjacents(position) {
    const [x,y] = position.map(i => parseInt(i));
    return [
      [x,y-1],
      [x-1,y],
      [x+1,y],
      [x,y+1]
    ]
  }

  move(direction) {
    const [x, y] = direction.map(i => parseInt(i));
    this.position[0] = x;
    this.position[1] = y;
  }

  turn(survive) {
    if(!this.alive) return;
    const targets = this.cave.units.filter(unit => unit.alive && unit.team !== this.team);
    const ocupied = this.cave.units.filter(unit => unit.alive && unit !== this).map(unit => `${unit.position}`);
    if(!targets.length) return true;
    const inRange = arraySet(targets.reduce((t,v) => t.concat(v.adjacents.map(p => `${p}`)), []))
      .filter(p => !~ocupied.indexOf(p) && !this.cave.walls[p] )
    if(!~inRange.indexOf(`${this.position}`)) this.findMove(inRange);
    const opponents = targets.filter(unit => ~this.adjacents.map(p => `${p}`).indexOf(`${unit.position}`));;
    if(opponents.length) {
      const target = opponents.sort((a,b) => a.hp - b.hp || a.position[1] - b.position[1] || a.position[0] - b.position[0])[0];
      target.hp -= this.power;
      if(survive && target.team === 'E' && !target.alive) throw new Error('Elf has died;');
    }
  }

  findMove(targets) {
    const ocupied = this.cave.units.filter(unit => unit.alive).map(unit => `${unit.position}`);
    const active = [{pos: this.position, dist: 0}];
    const visited = new Set(`${this.position}`);
    const path = {[this.position]: {prev: null, dist: 0}};
    while (active.length) {
      const {pos, dist} = active.shift();
      const adjs = this.constructor.getAdjacents(pos);
      for (let i = 0; i < adjs.length; i++) {
        const adj = adjs[i];
        if (this.cave.walls[adj] || ~ocupied.indexOf(`${adj}`)) continue;
        if (!path[adj] || path[adj].dist > dist + 1) path[adj] = {prev: `${pos}`, dist: dist+1};
        if (visited.has(`${adj}`)) continue;
        if (!~active.findIndex(act => `${act.pos}` === `${adj}`)) active.push({pos: adj, dist: dist+1})
      }
      visited.add(`${pos}`);
      // console.log(`Traversing path ${pos}, active: ${active.length}`)
    }
    let closest = targets.filter(target => path[target]).sort((a,b) => {
      const [ax, ay] = a.split(',').map(i => parseInt(i));
      const [bx, by] = b.split(',').map(i => parseInt(i));
      return path[a].dist - path[b].dist || ay - by || ax - bx;
    })[0];
    if(closest) {
      while(path[closest].dist > 1) {
        closest = path[closest].prev
      }
      this.move(closest.split(','));
    }
  }

}