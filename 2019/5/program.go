package main

import (
	"fmt"
	"strconv"
)

type program struct {
	pointer int
	memory  []int
	input   int
	output  int
}

func (p *program) adds(mode byte) {
	a := p.memory[p.pointer+1]
	b := p.memory[p.pointer+2]
	c := p.memory[p.pointer+3]
	if mode&1 == 0 {
		a = p.memory[a]
	}
	if mode&2 == 0 {
		b = p.memory[b]
	}
	p.memory[c] = a + b
	p.pointer += 4
}

func (p *program) muls(mode byte) {
	a := p.memory[p.pointer+1]
	b := p.memory[p.pointer+2]
	c := p.memory[p.pointer+3]
	if mode&1 == 0 {
		a = p.memory[a]
	}
	if mode&2 == 0 {
		b = p.memory[b]
	}
	p.memory[c] = a * b
	p.pointer += 4
}

func (p *program) ins() {
	a := p.memory[p.pointer+1]
	p.memory[a] = p.input
	p.pointer += 2
}

func (p *program) outs(mode byte) {
	a := p.memory[p.pointer+1]
	if mode&1 == 0 {
		a = p.memory[a]
	}
	p.output = a
	p.pointer += 2
}

func (p *program) run() int {
	halt := false
	for !halt {
		opcode, mode := p.parseOpcode()
		switch opcode {
		case 1:
			p.adds(mode)
		case 2:
			p.muls(mode)
		case 3:
			p.ins()
		case 4:
			p.outs(mode)
		case 99:
			halt = true
		default:
			p.pointer++
		}
	}
	return p.output
}

func (p *program) parseOpcode() (opcode int, mode byte) {
	instruction := p.memory[p.pointer]
	str := fmt.Sprintf("%05d", instruction)
	opcode, err := strconv.Atoi(str[3:])
	if err != nil {
		return
	}
	bit, err := strconv.ParseUint(str[:3], 2, 8)
	if err != nil {
		return
	}
	mode = uint8(bit)
	return
}

func createProgram(code []int, input int) program {
	memory := make([]int, len(code))
	copy(memory, code)
	return program{
		0,
		memory,
		input,
		0,
	}
}
