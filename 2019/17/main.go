package main

import (
	"fmt"
	"log"
	"strings"

	"github.com/mblonyox/adventofcode/pkg/2019/intcode"
	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

type grid map[complex128]rune

type direction complex128

const (
	top    direction = -1 + 0i
	bottom direction = 1 + 0i
	left   direction = 0 - 1i
	right  direction = 0 + 1i
)

var directions = map[rune]direction{
	'^': top,
	'v': bottom,
	'<': left,
	'>': right,
}

var dirToLeft = map[direction]direction{
	top:    left,
	bottom: right,
	left:   bottom,
	right:  top,
}

var dirToRight = map[direction]direction{
	top:    right,
	bottom: left,
	left:   top,
	right:  bottom,
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
	g := getCameraView(code)

	result1 = getResult1(g)
	result2 = getResult2(g)
}

func getResult1(g grid) (result int) {
	return sumAlignment(g)
}

func getResult2(g grid) (result int) {
	path := tracePath(g)
	pathStr := strings.Join(path, ",")
	m, a, b, c := splitPath(pathStr)
	fmt.Println(m, a, b, c)
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

func sumAlignment(g grid) (result int) {
outer:
	for p, r := range g {
		if r != '#' {
			continue
		}
		for _, d := range directions {
			if r := g[p+complex128(d)]; r != '#' {
				continue outer
			}
		}
		result += int(real(p) * imag(p))
	}
	return
}

func tracePath(g grid) (result []string) {
	result = []string{}
	var cur direction
	var pos complex128
	for p, r := range g {
		if dir, ok := directions[r]; ok {
			cur = dir
			pos = p
		}
	}
	forward := 0
	for {
		if g[pos+complex128(cur)] == '#' {
			forward++
			pos += complex128(cur)
			continue
		}
		if forward > 0 {
			result = append(result, fmt.Sprint(forward))
			forward = 0
		}
		if g[pos+complex128(dirToLeft[cur])] == '#' {
			result = append(result, "L")
			cur = dirToLeft[cur]
		} else if g[pos+complex128(dirToRight[cur])] == '#' {
			result = append(result, "R")
			cur = dirToRight[cur]
		} else {
			break
		}
	}
	return
}

func splitPath(path string) (Main, A, B, C string) {
	for a := 10; a > 0; a-- {
		A = getSubPath(path, a)
		if len(A) > 20 {
			continue
		}
		mainA := strings.ReplaceAll(path, A, "A")
		restA := getRestPath(mainA, "A")
		for b := 10; b > 0; b-- {
			B = getSubPath(restA, b)
			if len(B) > 20 {
				continue
			}
			mainB := strings.ReplaceAll(mainA, B, "B")
			restB := getRestPath(mainB, "A", "B")
			for c := 10; c > 0; c-- {
				C = getSubPath(restB, c)
				if len(C) > 20 {
					continue
				}
				Main = strings.ReplaceAll(mainB, C, "C")
				if !strings.ContainsAny(Main, "0123456789LR") {
					return
				}
				fmt.Println(Main)
			}
		}
	}
	return
}

func getRestPath(path string, chars ...string) (result string) {
	result = path
	for _, char := range chars {
		result = strings.ReplaceAll(result, char, "")
	}
	result = strings.Trim(result, ",")
	return
}

func getSubPath(path string, n int) string {
	p := strings.Split(path, ",")
	return strings.Trim(strings.Join(p[:n], ","), ",")
}
