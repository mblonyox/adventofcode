const assert = require('assert');
const {part1, part2} = require('./index');

const testCases1 = [
  {
    desc: '1122 produces a sum of 3 (1 + 2)',
    input: '1122',
    output: 3
  },
  {
    desc: '1111 produces 4',
    input: '1111',
    output: 4
  },
  {
    desc: '1234 produces 0',
    input: '1234',
    output: 0
  },
  {
    desc: '91212129 produces 9',
    input: '91212129',
    output: 9
  }
];

const testCases2 = [
  {
    desc: '1212 produces 6',
    input: '1212',
    output: 6
  },
  {
    desc: '1221 produces 0',
    input: '1221',
    output: 0
  },
  {
    desc: '123425 produces 4',
    input: '123425',
    output: 4
  },
  {
    desc: '123123 produces 12',
    input: '123123',
    output: 12
  },
  {
    desc: '12131415 produces 4',
    input: '12131415',
    output: 4
  }
]

describe('Day 1', function(){
  context('Part 1', function(){
    testCases1.forEach(c => {
      it(c.desc, function(){
        assert.equal(part1(c.input), c.output)
      });
    });
  })
  context('Part 2', function(){
    testCases2.forEach(c => {
      it(c.desc, function(){
        assert.equal(part2(c.input), c.output)
      });
    });
  })
})