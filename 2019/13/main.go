package main

import (
	"fmt"
	"log"
	"sync"

	"github.com/mblonyox/adventofcode/pkg/2019/intcode"
	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	termbox "github.com/nsf/termbox-go"
)

func main() {
	err := termbox.Init()
	if err != nil {
		panic(err)
	}
	defer termbox.Close()

	code, err := parser.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}

	ar := newArcade(code)
	ar.run()
}

type arcade struct {
	computer intcode.Computer
	score    int
}

func newArcade(code []int) arcade {
	code[0] = 2

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
		}
	}
}

func (a *arcade) run() {
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

func writeScore(s int) {
	text := "Score :"
	for i, r := range text {
		termbox.SetCell(i, 0, r, termbox.ColorWhite, termbox.ColorBlack)
	}
	score := fmt.Sprintf("%09d", s)
	for i, r := range score {
		termbox.SetCell(i+7, 0, r, termbox.ColorWhite, termbox.ColorBlack)
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
			writeScore(a.score)
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
		case 3:
			tile = '='
			fg = termbox.ColorCyan
			bg = termbox.ColorMagenta
		case 4:
			tile = 'o'
			fg = termbox.ColorRed
			bg = termbox.ColorBlack
		}
		termbox.SetCell(x, y+1, tile, fg, bg)
		termbox.Flush()
	}
}
