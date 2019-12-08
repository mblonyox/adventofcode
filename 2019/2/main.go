package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/pkg/2019/intcode"
	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
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
	com := intcode.New(code)
	return com.RunD2(12, 2)
}

func getResult2(code []int) (result int) {
	for noun := 0; noun < 100; noun++ {
		for verb := 0; verb < 100; verb++ {
			if com := intcode.New(code); com.RunD2(noun, verb) == 19690720 {
				return 100*noun + verb
			}
		}
	}
	return
}
