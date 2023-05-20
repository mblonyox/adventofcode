package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/2019/pkg/intcode"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	code, err := parser.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}

	result1 = getResult1(code)
	result2 = getResult2(code)
}

func getResult1(code []int) (result int) {
	instructions :=
		`	NOT A J
			NOT B T
			OR T J
			NOT C T
			OR T J
			AND D J
			WALK
		`
	return springdroid(code, instructions, false)
}

func getResult2(code []int) (result int) {
	instructions :=
		`	NOT A J
			NOT B T
			OR T J
			NOT C T
			OR T J
			AND D J
			NOT E T
			NOT T T
			OR H T
			AND T J
			RUN
		`
	return springdroid(code, instructions, false)
}

func springdroid(code []int, instructions string, debug bool) int {

	com := intcode.New(code)

	inputs := make([]int, len(instructions))
	for i, b := range instructions {
		inputs[i] = int(b)
	}
	// Feed the inputs
	go com.Input(inputs...)
	// Show outputs if debug is enabled
	if debug {
		out := make(chan int64)
		com.Output(out)
		go func() {
			for {
				o := <-out
				if o > 127 {
					fmt.Print(o)
				} else {
					fmt.Print(string(rune(o)))
				}
			}
		}()
	}
	results := com.RunD9()
	return int(results[len(results)-1])
}
