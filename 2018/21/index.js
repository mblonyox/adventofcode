const ora = require('ora');
const readInput = require('../../lib/readInput');

(async() => {
  const input = await readInput();
  const prog = new Program(input);

  const spinner = ora({spinner: 'pong', text: 'Please wait...'}).start();
  const result = prog.run();
  spinner.succeed('Here is the result :');
  console.log('Part 1 : ' + result.shift());
  console.log('Part 2 : ' + result.pop());
})();

class Program {

  constructor(input, reg0 = 0) {
    const [[,ip], ...instructions] = input.split('\n')
      .map(string => string.split(' ')
        .map(w => isNaN(parseInt(w)) ?  w : parseInt(w))
      );
    this.register = [reg0,0,0,0,0,0];
    this.ip = ip;
    this.instructions = instructions;
    this.var = instructions[28][1];
    this.opcodes = {
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
    };
  }

  get instruction() {
    return this.instructions[this.register[this.ip]];
  }

  set register0(value) {
    this.register = [value,0,0,0,0,0];
  }

  run() {
    let regs = [];
    while(this.instruction) {
      const [op , a , b , c] = this.instruction;
      this.register[c] = this.opcodes[op](a, b, this.register);
      this.register[this.ip]++;
      if(this.register[this.ip] === 28) {
        if(~regs.indexOf(this.register[this.var])) break;
        regs.push(this.register[this.var]);
      };
    }
    return regs;
  }
}
