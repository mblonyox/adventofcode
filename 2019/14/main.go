package main

import (
	"fmt"
	"log"
	"math"
	"strconv"
	"strings"

	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

var reactions map[string]reaction

func init() {
	reactions = map[string]reaction{}
}

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	lines, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}
	for _, line := range lines {
		r := parseLine(line)
		reactions[r.output] = r
	}

	result1 = getResult1()
	result2 = getResult2()
}

func getResult1() (result int) {
	return required("FUEL", 1, map[string]int{})
}

func getResult2() (result int) {
	return binarySearch(1000000000000, 0, 1000000000000, func(amount int) int {
		return required("FUEL", amount, map[string]int{})
	})
}

func parseLine(line string) reaction {
	inOut := strings.Split(line, " => ")
	inputs := map[string]int{}
	for _, in := range strings.Split(inOut[0], ", ") {
		chem := strings.Split(in, " ")
		inputs[chem[1]], _ = strconv.Atoi(chem[0])
	}
	out := strings.Split(inOut[1], " ")
	output := out[1]
	count, _ := strconv.Atoi(out[0])
	return reaction{
		inputs,
		output,
		count,
	}
}

type reaction struct {
	inputs map[string]int
	output string
	count  int
}

func required(chem string, amount int, extra map[string]int) (result int) {
	if chem == "ORE" {
		return amount
	}
	amount -= extra[chem]
	react := reactions[chem]
	mul := int(math.Ceil(float64(amount) / float64(react.count)))
	extra[chem] = mul*react.count - amount
	for input, count := range react.inputs {
		result += required(input, count*mul, extra)
	}
	return
}

func binarySearch(upper, lower, target int, f func(int) int) (result int) {
	for lower < upper {
		result = (lower + upper + 1) / 2
		if f(result) <= target {
			lower = result
		} else {
			upper = result - 1
		}
	}
	return
}
