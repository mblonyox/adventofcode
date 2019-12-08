package intcode

import (
	"fmt"
	"strconv"
)

// New make a computer object
func New(code []int) Computer {
	memory := make([]int, len(code))
	copy(memory, code)
	return Computer{
		memory: memory,
		inputs: make(chan int, 8),
	}
}

// Computer is object which store the code into the memory
type Computer struct {
	memory  []int
	pointer int
	inputs,
	outputs chan int
}

// Input into the channel
func (c *Computer) Input(inputs ...int) {
	for _, input := range inputs {
		c.inputs <- input
	}
}

// Close the inputs channel
func (c *Computer) Close() {
	close(c.inputs)
}

func (c *Computer) adds(mode byte) {
	p1 := c.memory[c.pointer+1]
	p2 := c.memory[c.pointer+2]
	p3 := c.memory[c.pointer+3]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if mode&2 == 0 {
		p2 = c.memory[p2]
	}
	c.memory[p3] = p1 + p2
	c.pointer += 4
}

func (c *Computer) multiplies(mode byte) {
	p1 := c.memory[c.pointer+1]
	p2 := c.memory[c.pointer+2]
	p3 := c.memory[c.pointer+3]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if mode&2 == 0 {
		p2 = c.memory[p2]
	}
	c.memory[p3] = p1 * p2
	c.pointer += 4
}

func (c *Computer) input(mode byte) {
	p1 := c.memory[c.pointer+1]
	c.memory[p1] = <-c.inputs
	c.pointer += 2
}

func (c *Computer) output(mode byte) int {
	p1 := c.memory[c.pointer+1]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if c.outputs != nil {
		c.outputs <- p1
	}
	c.pointer += 2
	return p1
}

func (c *Computer) jumpIfTrue(mode byte) {
	p1 := c.memory[c.pointer+1]
	p2 := c.memory[c.pointer+2]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if mode&2 == 0 {
		p2 = c.memory[p2]
	}
	if p1 != 0 {
		c.pointer = p2
	} else {
		c.pointer += 3
	}
}

func (c *Computer) jumpIfFalse(mode byte) {
	p1 := c.memory[c.pointer+1]
	p2 := c.memory[c.pointer+2]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if mode&2 == 0 {
		p2 = c.memory[p2]
	}
	if p1 == 0 {
		c.pointer = p2
	} else {
		c.pointer += 3
	}
}

func (c *Computer) lessThan(mode byte) {
	p1 := c.memory[c.pointer+1]
	p2 := c.memory[c.pointer+2]
	p3 := c.memory[c.pointer+3]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if mode&2 == 0 {
		p2 = c.memory[p2]
	}
	if p1 < p2 {
		c.memory[p3] = 1
	} else {
		c.memory[p3] = 0
	}
	c.pointer += 4
}

func (c *Computer) equals(mode byte) {
	p1 := c.memory[c.pointer+1]
	p2 := c.memory[c.pointer+2]
	p3 := c.memory[c.pointer+3]
	if mode&1 == 0 {
		p1 = c.memory[p1]
	}
	if mode&2 == 0 {
		p2 = c.memory[p2]
	}
	if p1 == p2 {
		c.memory[p3] = 1
	} else {
		c.memory[p3] = 0
	}
	c.pointer += 4
}

func (c *Computer) parseInstruction() (opcode int, mode byte) {
	instruction := c.memory[c.pointer]
	str := fmt.Sprintf("%05d", instruction)
	opcode, err := strconv.Atoi(str[3:])
	if err != nil {
		return
	}
	bit, err := strconv.ParseUint(str[:3], 2, 8)
	if err != nil {
		return
	}
	mode = byte(bit)
	return
}

// RunD2 run the computer with Day 2 Opcodes
func (c *Computer) RunD2(noun, verb int) int {
	c.memory[1] = noun
	c.memory[2] = verb
	halt := false
	for !halt {
		opcode, mode := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(mode)
		case 2:
			c.multiplies(mode)
		case 99:
			halt = true
		default:
			c.pointer++
		}
	}
	return c.memory[0]
}

// RunD5P1 run the computer with Day 5 Part 1 Opcodes
func (c *Computer) RunD5P1(inputs ...int) int {
	c.Input(inputs...)
	outputs := []int{}
	halt := false
	for !halt {
		opcode, mode := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(mode)
		case 2:
			c.multiplies(mode)
		case 3:
			c.input(mode)
		case 4:
			outputs = append(outputs, c.output(mode))
		case 99:
			halt = true
		default:
			c.pointer++
		}
	}
	return outputs[len(outputs)-1]
}

// RunD5P2 run the computer with Day 5 Part 2 Opcodes
func (c *Computer) RunD5P2(inputs ...int) int {
	c.Input(inputs...)
	halt := false
	outputs := []int{}
	for !halt {
		opcode, mode := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(mode)
		case 2:
			c.multiplies(mode)
		case 3:
			c.input(mode)
		case 4:
			outputs = append(outputs, c.output(mode))
		case 5:
			c.jumpIfTrue(mode)
		case 6:
			c.jumpIfFalse(mode)
		case 7:
			c.lessThan(mode)
		case 8:
			c.equals(mode)
		case 99:
			halt = true
		default:
			c.pointer++
		}
	}
	return outputs[len(outputs)-1]
}

// Listen other computer outputs into this computer inputs
func (c *Computer) Listen(c1 *Computer) {
	c1.outputs = c.inputs
}
