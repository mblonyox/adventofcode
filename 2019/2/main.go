package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {
	input, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer input.Close()

	var result1, result2 int

	// parse input to slice of int
	csvReader := csv.NewReader(input)
	record, err := csvReader.Read()
	if err != nil {
		log.Fatal(err)
	}
	program := make([]int, len(record))
	for i, s := range record {
		temp, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			log.Fatal(err)
		}
		program[i] = int(temp)
	}

	// 1202 program alarm
	result1 = runProgram(program, 12, 2)

	// Find noun & verb to produce output 19690720
outer:
	for noun := 0; noun < 100; noun++ {
		for verb := 0; verb < 100; verb++ {
			if runProgram(program, noun, verb) == 19690720 {
				result2 = 100*noun + verb
				break outer
			}
		}
	}

	fmt.Printf("Part 1: %d \r\n", result1)
	fmt.Printf("Part 2: %d \r\n", result2)
}

func adds(state []int, pointer int) {
	a := state[pointer+1]
	b := state[pointer+2]
	c := state[pointer+3]
	state[c] = state[a] + state[b]
}

func multiplies(state []int, pointer int) {
	a := state[pointer+1]
	b := state[pointer+2]
	c := state[pointer+3]
	state[c] = state[a] * state[b]
}

func runProgram(program []int, noun, verb int) int {
	pointer := 0
	state := make([]int, len(program))
	copy(state, program)
	state[1] = noun
	state[2] = verb

	for state[pointer] != 99 {
		switch state[pointer] {
		case 1:
			adds(state, pointer)
			pointer += 4
		case 2:
			multiplies(state, pointer)
			pointer += 4
		default:
			pointer++
		}
	}

	return state[0]
}
