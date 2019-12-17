package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/pkg/2019/intcode"
	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

type grid map[complex128]rune

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	code, err := parser.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}
	g := getCameraView(code)

	result1 = getResult1(g)
	result2 = getResult2()
}

func getResult1(g grid) (result int) {
	return sumAlignment(g)
}

func getResult2() (result int) {
	return
}

func getCameraView(code []int) grid {
	com := intcode.New(code)
	out := com.RunD9()
	g := grid{}
	cur := 0 + 0i
	for _, n := range out {
		if n == 10 {
			cur = complex(real(cur)+1, 0)
		} else {
			g[cur] = rune(n)
			cur += 0 + 1i
		}
	}
	return g
}

var directions = []complex128{
	-1 + 0i,
	0 + 1i,
	1 + 0i,
	0 - 1i,
}

func sumAlignment(g grid) (result int) {
outer:
	for p, r := range g {
		if r != '#' {
			continue
		}
		for _, d := range directions {
			if r := g[p+d]; r != '#' {
				continue outer
			}
		}
		result += int(real(p) * imag(p))
	}
	return
}
