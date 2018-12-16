const readInput = require('../../lib/readInput');

(async() => {
  const input = await readInput();
  const [input1, input2] = input.split('\n\n\n');
  const samples = input1.split('\n\n')
    .map(sample => {
      let [,before, instruction, after] = sample.match(/Before: \[([\d, ]+)\]\n([\d ]+)\nAfter:  \[([\d, ]+)\]/);
      before = before.split(',').map(d => parseInt(d));
      instruction = instruction.split(' ').map(d => parseInt(d));
      after = after.split(',').map(d => parseInt(d));
      return {before, instruction, after};
    });
  const codes = new Array(16);
  samples.forEach(sample => {
    sample.possibleOps = [];
    Object.keys(opcodes).forEach(key => {
      const {before, instruction, after} = sample;
      if(opcodes[key](before, instruction).toString() === after.toString()) sample.possibleOps.push(key);
    })
    let code = sample.instruction[0];
    if(!codes[code]) codes[code] = sample.possibleOps.slice();
    else codes[code] = codes[code].filter(op => ~sample.possibleOps.indexOf(op));
  });
  console.log('Part 1 : ' + samples.filter(sample => sample.possibleOps.length >= 3).length);

  // Part 2
  const mappedCode = {};
  while(codes.some(code => code.length)) {
    for (let i = 0; i < codes.length; i++) {
      const code = codes[i];
      if(code && code.length === 1) {
        const op = code[0];
        mappedCode[i] = op;
        for (let j = 0; j < codes.length; j++) {
          if(~codes[j].indexOf(op)) codes[j].splice(codes[j].indexOf(op), 1);
        }
      }
    }
  }

  const testInput = input2.trim().split('\n');
  let register = [0,0,0,0];
  testInput.forEach(input => {
    const instruction = input.split(' ').map(d => parseInt(d));
    const op = mappedCode[instruction[0]]
    register = opcodes[op](register, instruction);
  })
  console.log('Part 2 : ' + register[0]);

})();

const opbasic = (cb) => (before, instruction) => {
  const [op , a , b , c] = instruction;
  let result = before.slice()
  result.splice(c, 1, cb(a, b, before))
  return result;
}

const opcodes = {
  'addr' : opbasic((a, b, before) => before[a] + before[b]),
  'addi' : opbasic((a, b, before) => before[a] + b),
  'mulr' : opbasic((a, b, before) => before[a] * before[b]),
  'muli' : opbasic((a, b, before) => before[a] * b),
  'banr' : opbasic((a, b, before) => before[a] & before[b]),
  'bani' : opbasic((a, b, before) => before[a] & b),
  'borr' : opbasic((a, b, before) => before[a] | before[b]),
  'bori' : opbasic((a, b, before) => before[a] | b),
  'setr' : opbasic((a, b, before) => before[a]),
  'seti' : opbasic((a, b, before) => a),
  'gtir' : opbasic((a, b, before) => a > before[b] ? 1 : 0),
  'gtri' : opbasic((a, b, before) => before[a] > b ? 1 : 0),
  'gtrr' : opbasic((a, b, before) => before[a] > before[b] ? 1 : 0),
  'eqir' : opbasic((a, b, before) => a === before[b] ? 1 : 0),
  'eqri' : opbasic((a, b, before) => before[a] === b ? 1 : 0),
  'eqrr' : opbasic((a, b, before) => before[a] === before[b] ? 1 : 0),
}
