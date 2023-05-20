package main

import (
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/mblonyox/adventofcode/2019/pkg/intcode"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
	termbox "github.com/nsf/termbox-go"
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

func getResult1(code []int) (result int) {
	arc := newArcade(code)
	arc.run()
	return arc.blocks
}

func getResult2(code []int) (result int) {
	code[0] = 2
	arc := newArcade(code)
	arc.run()
	return arc.score
}

type arcade struct {
	computer intcode.Computer
	blocks,
	score,
	xBall,
	xPaddle int
}

func newArcade(code []int) arcade {
	return arcade{
		computer: intcode.New(code),
	}
}

func (a *arcade) joystick() {
	for {
		switch ev := termbox.PollEvent(); ev.Type {
		case termbox.EventKey:
			if ev.Key == termbox.KeyArrowLeft {
				a.computer.Input(-1)
			} else if ev.Key == termbox.KeyArrowRight {
				a.computer.Input(1)
			} else {
				a.computer.Input(0)
			}
		case termbox.EventInterrupt:
			log.Fatal("Terminated")
		}
	}
}

func (a *arcade) auto() {
	// to slow down the animation
	time.Sleep(17 * time.Millisecond)
	if a.xBall == a.xPaddle || a.xPaddle == 0 {
		a.computer.Input(0)
	} else if a.xBall < a.xPaddle {
		a.computer.Input(-1)
	} else {
		a.computer.Input(1)
	}
}

func (a *arcade) run() {
	err := termbox.Init()
	if err != nil {
		panic(err)
	}
	defer termbox.Close()

	ch := make(chan int64)
	var wg sync.WaitGroup
	a.computer.Output(ch)
	go a.joystick()
	go a.draw(ch)
	wg.Add(1)
	go func() {
		a.computer.RunD9()
		wg.Done()
	}()
	wg.Wait()
}

func (a *arcade) writeScore() {
	text := "Score :"
	for i, r := range text {
		termbox.SetCell(i, 1, r, termbox.ColorWhite, termbox.ColorBlack)
	}
	score := fmt.Sprintf("%09d", a.score)
	for i, r := range score {
		termbox.SetCell(i+7, 1, r, termbox.ColorWhite, termbox.ColorBlack)
	}
}

func (a *arcade) draw(ch chan int64) {
	for {
		x := int(<-ch)
		y := int(<-ch)
		id, ok := <-ch

		if !ok {
			return
		}

		if x == -1 && y == 0 {
			a.score = int(id)
			a.writeScore()
			continue
		}

		var tile rune
		var fg, bg termbox.Attribute
		switch id {
		case 0:
			tile = ' '
			fg = termbox.ColorWhite
			bg = termbox.ColorBlack
		case 1:
			tile = ' '
			fg = termbox.ColorBlack
			bg = termbox.ColorWhite
		case 2:
			tile = '#'
			fg = termbox.ColorYellow
			bg = termbox.ColorBlack
			a.blocks++
		case 3:
			tile = '='
			fg = termbox.ColorCyan
			bg = termbox.ColorMagenta
			a.xPaddle = x
		case 4:
			tile = 'o'
			fg = termbox.ColorRed
			bg = termbox.ColorBlack
			a.xBall = x
			go a.auto()
		}
		termbox.SetCell(x, y+2, tile, fg, bg)
		termbox.Flush()
	}
}
