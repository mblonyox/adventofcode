package main

import (
	"fmt"
	"log"
	"sync"

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
	result2 = getResult2()
}

func getResult1(code []int) (result int) {
	r := newRobot(code)
	r.run()
	return len(r.panels)
}

func getResult2() (result int) {
	return
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

func (r *robot) run() {
	ch := make(chan int64)
	r.computer.Output(ch)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		r.computer.RunD9(0)
		wg.Done()
	}()
	go func() {
		for {
			r.paint(<-ch == 1)
			r.turn(<-ch == 1)
			r.see()
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
