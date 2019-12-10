package intcode

import (
	"fmt"
	"strconv"
)

// New make a computer object
func New(code []int) Computer {
	memory := make([]int64, len(code))
	for i, n := range code {
		memory[i] = int64(n)
	}
	return Computer{
		memory: memory,
		inputs: make(chan int64, 8),
	}
}

// Computer is object which store the code into the memory
type Computer struct {
	memory []int64
	relative,
	pointer int
	inputs,
	outputs chan int64
}

// Input into the channel
func (c *Computer) Input(inputs ...int) {
	for _, input := range inputs {
		c.inputs <- int64(input)
	}
}

// Close the inputs channel
func (c *Computer) Close() {
	close(c.inputs)
}

func (c *Computer) adds(p1, p2, p3 int64) {
	c.writeMemory(int(p3), p1+p2)
	c.pointer += 4
}

func (c *Computer) multiplies(p1, p2, p3 int64) {
	c.writeMemory(int(p3), p1*p2)
	c.pointer += 4
}

func (c *Computer) input(p1 int64) {
	c.writeMemory(int(p1), <-c.inputs)
	c.pointer += 2
}

func (c *Computer) output(p1 int64) int64 {
	if c.outputs != nil {
		c.outputs <- p1
	}
	c.pointer += 2
	return p1
}

func (c *Computer) jumpIfTrue(p1, p2 int64) {
	if p1 != 0 {
		c.pointer = int(p2)
	} else {
		c.pointer += 3
	}
}

func (c *Computer) jumpIfFalse(p1, p2 int64) {
	if p1 == 0 {
		c.pointer = int(p2)
	} else {
		c.pointer += 3
	}
}

func (c *Computer) lessThan(p1, p2, p3 int64) {
	value := int64(0)
	if p1 < p2 {
		value = 1
	}
	c.writeMemory(int(p3), value)
	c.pointer += 4
}

func (c *Computer) equals(p1, p2, p3 int64) {
	value := int64(0)
	if p1 == p2 {
		value = 1
	}
	c.writeMemory(int(p3), value)
	c.pointer += 4
}

func (c *Computer) adjust(p1 int64) {
	c.relative += int(p1)
	c.pointer += 2
}

func (c *Computer) parseInstruction() (opcode, p1, p2, p3 int64) {
	instruction := c.memory[c.pointer]
	str := fmt.Sprintf("%05d", instruction)
	opcode, err := strconv.ParseInt(str[3:], 10, 64)
	if err != nil {
		return
	}
	if opcode == 3 {
		p1 = c.getParam(c.pointer+1, "1")
		if str[2:3] == "2" {
			p1 += int64(c.relative)
		}
	} else {
		p1 = c.getParam(c.pointer+1, str[2:3])
	}
	p2 = c.getParam(c.pointer+2, str[1:2])
	if opcode == 1 || opcode == 2 || opcode == 7 || opcode == 8 {
		p3 = c.getParam(c.pointer+3, "1")
		if str[0:1] == "2" {
			p3 += int64(c.relative)
		}
	} else {
		p3 = c.getParam(c.pointer+3, str[0:1])
	}
	return
}

func (c *Computer) getParam(pointer int, mode string) (result int64) {
	value := c.readMemory(pointer)
	switch mode {
	case "0":
		return c.readMemory(int(value))
	case "1":
		return value
	case "2":
		return c.readMemory(int(value) + c.relative)
	}
	return
}

func (c *Computer) readMemory(position int) (result int64) {
	length := len(c.memory)
	if position >= 0 && position < length {
		return c.memory[position]
	}
	return
}

func (c *Computer) writeMemory(position int, value int64) {
	length := len(c.memory)
	if position < 0 {
		return
	}
	if position >= length {
		c.memory = append(c.memory, make([]int64, position-length+1)...)
	}
	c.memory[position] = value
}

// RunD2 run the computer with Day 2 Opcodes
func (c *Computer) RunD2(noun, verb int) int {
	c.memory[1] = int64(noun)
	c.memory[2] = int64(verb)
	halt := false
	for !halt {
		opcode, p1, p2, p3 := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(p1, p2, p3)
		case 2:
			c.multiplies(p1, p2, p3)
		case 99:
			halt = true
		default:
			c.pointer++
		}
	}
	return int(c.memory[0])
}

// RunD5P1 run the computer with Day 5 Part 1 Opcodes
func (c *Computer) RunD5P1(inputs ...int) int {
	c.Input(inputs...)
	outputs := []int{}
	halt := false
	for !halt {
		opcode, p1, p2, p3 := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(p1, p2, p3)
		case 2:
			c.multiplies(p1, p2, p3)
		case 3:
			c.input(p1)
		case 4:
			outputs = append(outputs, int(c.output(p1)))
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
		opcode, p1, p2, p3 := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(p1, p2, p3)
		case 2:
			c.multiplies(p1, p2, p3)
		case 3:
			c.input(p1)
		case 4:
			outputs = append(outputs, int(c.output(p1)))
		case 5:
			c.jumpIfTrue(p1, p2)
		case 6:
			c.jumpIfFalse(p1, p2)
		case 7:
			c.lessThan(p1, p2, p3)
		case 8:
			c.equals(p1, p2, p3)
		case 99:
			halt = true
		default:
			c.pointer++
		}
	}
	return outputs[len(outputs)-1]
}

// RunD9 run the computer with Day 9 Part 1 Opcodes
func (c *Computer) RunD9(inputs ...int) []int64 {
	c.Input(inputs...)
	halt := false
	outputs := []int64{}
	for !halt {
		opcode, p1, p2, p3 := c.parseInstruction()
		switch opcode {
		case 1:
			c.adds(p1, p2, p3)
		case 2:
			c.multiplies(p1, p2, p3)
		case 3:
			c.input(p1)
		case 4:
			outputs = append(outputs, c.output(p1))
		case 5:
			c.jumpIfTrue(p1, p2)
		case 6:
			c.jumpIfFalse(p1, p2)
		case 7:
			c.lessThan(p1, p2, p3)
		case 8:
			c.equals(p1, p2, p3)
		case 9:
			c.adjust(p1)
		case 99:
			halt = true
		default:
			c.pointer++
		}
	}
	return outputs
}

// Listen other computer outputs into this computer inputs
func (c *Computer) Listen(c1 *Computer) {
	c1.outputs = c.inputs
}
