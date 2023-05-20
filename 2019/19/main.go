package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/2019/pkg/intcode"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

type intCode []int

func (code intCode) scan(x, y int) bool {
	com := intcode.New(code)
	out := com.RunD9(x, y)
	return out[len(out)-1] == 1
}

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	code, err := parser.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}
	com := intCode(code)

	result1 = getResult1(com)
	result2 = getResult2(com)
}

func getResult1(com intCode) (result int) {
	for x := 0; x < 50; x++ {
		for y := 0; y < 50; y++ {
			if com.scan(x, y) {
				result++
			}
		}
	}
	return
}

func getResult2(com intCode) (result int) {
	var x, y int
	for !com.scan(x, y+99) {
		x++
		for !com.scan(x+99, y) {
			y++
		}
	}
	return x*10000 + y
}
