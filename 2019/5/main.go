package main

import (
	"fmt"
	"log"

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
	p1 := createProgram(code, 1)
	result1 = p1.run1()
	p2 := createProgram(code, 5)
	result2 = p2.run2()

}
