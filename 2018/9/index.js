const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput();
  const [,playerNumber, lastMarble] = /(\d+) players; last marble is worth (\d+) points/.exec(input);

  const getMaxScore = (p,m) => {

    const playersScore = new Array(parseInt(p)).fill(0);
    const circle = new Circle();

    for (let i = 0; i <= m; i++) {
      if(i && i % 23 === 0) {
        playersScore[i%p] += i + circle.get();
      } else {
        circle.add(i);
      }
    }

    return Math.max(...playersScore);
  }

  // Part 1
  console.log('Part 1 : ' + getMaxScore(playerNumber, lastMarble));
  // Part 2
  console.log('Part 2 : ' + getMaxScore(playerNumber, lastMarble*100));
})();

class Node {
  constructor( data ) {
    this.data = data;
    this.next = null;
    this.prev = null;
  }
}

class Circle {
  constructor() {
    this.current = null
  }

  _rotate2() {
    this.current = this.current.next.next
  }

  _rotate7() {
    this.current = this.current.prev.prev.prev.prev.prev.prev.prev
  }

  add(item) {
    let node = new Node(item);
    if(!this.current) {
      node.prev = node;
      node.next = node;
      this.current = node;
    } else {
      this._rotate2();
      node.prev = this.current.prev;
      node.next = this.current;
      this.current.prev.next = node;
      this.current.prev = node;
      this.current = node;
    }
  }

  get() {
    this._rotate7();
    this.current.prev.next = this.current.next;
    this.current.next.prev = this.current.prev;
    const data = this.current.data;
    this.current = this.current.next;
    return data;
  }
}
