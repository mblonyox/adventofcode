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

func getResult1(code []int) int {
	com := intcode.New(code)
	defer com.Close()
	return com.RunD5P1(1)
}

func getResult2(code []int) int {
	com := intcode.New(code)
	defer com.Close()
	return com.RunD5P2(5)
}
