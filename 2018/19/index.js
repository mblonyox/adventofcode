const readInput = require('../lib/readInput');

(async() => {
  const input = await readInput('test.txt');
  const [[,ip], ...program] = input.split('\n')
    .map(string => string.split(' ')
      .map(w => isNaN(parseInt(w)) ?  w : parseInt(w))
    );
  let register = [0,0,0,0,0,0];
  const var1 = program[8][3];
  const var2 = program[12][3];
  const var3 = program[4][2];

  const run = (optimized = true) => {
    while(true) {
      const instruction = program[register[ip]]
      if(!instruction) break;
      // Optimize the loop
      if(optimized && register[ip] === 8) {
        const mod = register[var3]%register[var2] === 0;
        const mul = register[var3]/register[var2];
        if(mod && register[var1] < mul) register[var1] = mul;
        else register[var1] = register[var3]+1;
      }
      else opbasic(register, instruction);
      register[ip]++;
      // console.log(register)
    }
  }

  run();
  console.log('Part 1 : ' + register[0]);

  register = [1,0,0,0,0,0];
  run();
  console.log('Part 2 : ' + register[0]);

})();

const opbasic = (register, instruction) => {
  const [op , a , b , c] = instruction;
  register[c] = opcodes[op](a, b, register);
}

const opcodes = {
  'addr' : (a, b, register) => register[a] + register[b],
  'addi' : (a, b, register) => register[a] + b,
  'mulr' : (a, b, register) => register[a] * register[b],
  'muli' : (a, b, register) => register[a] * b,
  'banr' : (a, b, register) => register[a] & register[b],
  'bani' : (a, b, register) => register[a] & b,
  'borr' : (a, b, register) => register[a] | register[b],
  'bori' : (a, b, register) => register[a] | b,
  'setr' : (a, b, register) => register[a],
  'seti' : (a, b, register) => a,
  'gtir' : (a, b, register) => a > register[b] ? 1 : 0,
  'gtri' : (a, b, register) => register[a] > b ? 1 : 0,
  'gtrr' : (a, b, register) => register[a] > register[b] ? 1 : 0,
  'eqir' : (a, b, register) => a === register[b] ? 1 : 0,
  'eqri' : (a, b, register) => register[a] === b ? 1 : 0,
  'eqrr' : (a, b, register) => register[a] === register[b] ? 1 : 0,
}

