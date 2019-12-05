package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/tools"
)

func main() {

	var result1, result2 int
	defer tools.StopSpinner(tools.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	code, err := tools.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}
	p1 := createProgram(code, 1)
	result1 = p1.run()

}
