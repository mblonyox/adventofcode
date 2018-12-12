const readInput = require('../../lib/readInput');

(async() => {
  const input = await readInput();
  let initialState = input.match(/initial state: ([#.]+)/)[1];
  const spreads = {};
  input.match(/[#.]{5} => [#.]/g).forEach((string) => {
    const [,key,value] = string.match(/([#.]{5}) => ([#.])/);
    spreads[key] = value;
  });

  const getGeneration = (n) => {
    let state = initialState;
    let first = 0;
    for (let i = 0; i < n; i++) {
      if(state[0] === '#') {
        state = '..' + state;
        first -= 2;
      }
      if(state[state.length-1] === '#') state = state + '..';
      state = state.split('').map((char, index) => {
        const key = (state[index-2] || '.') +
          (state[index-1] || '.') +
          char +
          (state[index+1] || '.') +
          (state[index+2] || '.')
        return spreads[key];
      }).join('');
      const move = state.indexOf('#');
      state = state.slice(move);
      first += move;
      // console.log(`Gen ${i+1} from index ${first} : ${state}`);
    }
    return {state, first};
  }

  // Part 1
  const gen20 = getGeneration(20);
  const part1 = gen20.state.split('').reduce((t,v,i) => t += v=== '#' ? (i+gen20.first) : 0, 0);
  console.log('Part 1 : ' + part1);

  // Part 2
  const gen1000 = getGeneration(1000);
  const scale = 50000000000 - 1000 + gen1000.first;
  const part2 = gen1000.state.split('').reduce((t,v,i) => t += v=== '#' ? (i+scale) : 0, 0);
  console.log('Part 2 : '+ part2);

})();
