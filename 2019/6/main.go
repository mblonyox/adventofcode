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

	input, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(input)
}

func mapInput(input []string) (result map[string]string) {
	result = map[string]string{}
	for _, str := range input {
		result[str[4:]] = str[:3]
	}
	return
}
