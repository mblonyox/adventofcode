package main

import (
	"fmt"
	"log"
	"math"

	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

func main() {

	var result1 int
	var result2 []rune
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\n", result1)
		printImage(result2)
	})

	inputs, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}
	input := inputs[0]

	result1 = getResult1(input)
	result2 = getResult2(input)
}

func getResult1(input string) (result int) {
	lowest0 := math.MaxInt8

	for i := 0; i < len(input); i += 150 {
		layer := input[i : i+150]
		var count0, count1, count2 int
		for _, r := range layer {
			switch r {
			case '0':
				count0++
			case '1':
				count1++
			case '2':
				count2++
			}
		}
		if count0 < lowest0 {
			result = count1 * count2
			lowest0 = count0
		}
	}

	return
}

func getResult2(input string) (image []rune) {
	image = make([]rune, 150)

	for i := 0; i < len(input); i += 150 {
		layer := input[i : i+150]
		for i, r := range layer {
			if image[i] == '█' || image[i] == '░' {
				continue
			}
			if r == '0' {
				image[i] = '█'
			}
			if r == '1' {
				image[i] = '░'
			}
		}
	}

	return
}

func printImage(image []rune) {
	fmt.Println("Part 2:")
	for i := 0; i < len(image); i += 25 {
		layer := image[i : i+25]
		fmt.Println(string(layer))
	}
}
