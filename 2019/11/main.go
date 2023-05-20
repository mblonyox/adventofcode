package main

import (
	"fmt"
	"log"
	"sync"

	"github.com/mblonyox/adventofcode/2019/pkg/intcode"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

func main() {

	var result1 int
	var result2 [][]rune
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\n", result1)
		fmt.Println("Part 2:")
		for _, line := range result2 {
			fmt.Println(string(line))
		}
	})

	code, err := parser.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}

	result1 = getResult1(code)
	result2 = getResult2(code)
}

func getResult1(code []int) (result int) {
	r := newRobot(code)
	r.run()
	return len(r.panels)
}

func getResult2(code []int) (result [][]rune) {
	r := newRobot(code)
	r.panels[0+0i] = true
	r.run()
	return r.drawPanel()
}

type direction int

const (
	up direction = iota
	right
	down
	left
)

type robot struct {
	computer intcode.Computer
	panels   map[complex128]bool
	position complex128
	facing   direction
}

func newRobot(code []int) robot {
	return robot{
		computer: intcode.New(code),
		panels:   make(map[complex128]bool),
	}
}

func (r *robot) run(input ...int) {
	ch := make(chan int64)
	r.computer.Output(ch)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		r.computer.RunD9()
		wg.Done()
	}()
	go func() {
		for {
			r.see()
			r.paint(<-ch == 1)
			r.turn(<-ch == 1)
		}
	}()
	wg.Wait()
}

func (r *robot) see() {
	panel := r.panels[r.position]
	if panel {
		r.computer.Input(1)
	} else {
		r.computer.Input(0)
	}
}

func (r *robot) paint(isWhite bool) {
	r.panels[r.position] = isWhite
}

func (r *robot) turn(toRight bool) {
	if toRight {
		r.facing = (r.facing + 1) % 4
	} else {
		r.facing = (r.facing + 3) % 4
	}

	switch r.facing {
	case up:
		r.position += 0 + 1i
	case right:
		r.position += 1 + 0i
	case down:
		r.position += 0 - 1i
	case left:
		r.position += -1 + 0i
	}
}

func (r *robot) drawPanel() [][]rune {
	var maxX, minX, maxY, minY float64
	for k := range r.panels {
		x := real(k)
		y := imag(k)
		if x > maxX {
			maxX = x
		}
		if x < minX {
			minX = x
		}
		if y > maxY {
			maxY = y
		}
		if y < minY {
			minY = y
		}
	}
	width := int(maxX - minX + 1)
	height := int(maxY - minY + 1)

	grid := make2dGrid(width, height, '█')

	for k, isWhite := range r.panels {
		if isWhite {
			x := int(real(k) - minX)
			y := int(maxY - imag(k))
			grid[y][x] = '░'
		}
	}
	return grid
}

func make2dGrid(width, height int, initial rune) [][]rune {
	grid := make([][]rune, height)
	for i := 0; i < len(grid); i++ {
		grid[i] = make([]rune, width)
		for j := 0; j < len(grid[i]); j++ {
			grid[i][j] = initial
		}
	}
	return grid
}
