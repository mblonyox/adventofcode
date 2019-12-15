package main

import (
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/mblonyox/adventofcode/pkg/2019/intcode"
	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
	"github.com/nsf/termbox-go"
)

var offsetX = 21
var offsetY = 21
var delay = 50 * time.Microsecond

type gridmap map[complex128]bool

type movcmd int

const (
	north movcmd = iota + 1
	south
	west
	east
)

var movdir = map[movcmd]complex128{
	north: -1 + 0i,
	south: 1 + 0i,
	west:  0 + -1i,
	east:  0 + 1i,
}

var movback = map[movcmd]movcmd{
	north: south,
	south: north,
	west:  east,
	east:  west,
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

	grid := make(gridmap)

	result1, target := getResult1(code, grid)
	result2 = getResult2(grid, target)
	termbox.Close()
}

func getResult1(code []int, grid gridmap) (result int, target complex128) {
	dr := newDroid(code)
	go dr.start()
	result, target = dr.path(0, 0, grid)
	return
}

func getResult2(grid gridmap, start complex128) (result int) {
	setOxygen(start)
	delete(grid, start)
	tips := []complex128{start}
	for len(grid) > 0 {
		time.Sleep(1000 * delay)
		result++
		nextTips := []complex128{}
		for _, tip := range tips {
			for _, dir := range movdir {
				pos := tip + dir
				if grid[pos] {
					setOxygen(pos)
					delete(grid, pos)
					nextTips = append(nextTips, pos)
				}
			}
		}
		tips = nextTips
	}
	return
}

func initScreen() {
	for i := 0; i < 2*offsetX-1; i++ {
		for j := 0; j < 2*offsetY-1; j++ {
			termbox.SetCell(i, j, ' ', termbox.ColorDefault, termbox.ColorWhite)
		}
	}
	termbox.SetCell(offsetX, offsetY, 'D', termbox.ColorBlue, termbox.ColorBlack)
	termbox.Flush()
}

func setWall(pos complex128) {
	x := offsetX + int(imag(pos))
	y := offsetY + int(real(pos))
	termbox.SetCell(x, y, '#', termbox.ColorRed, termbox.ColorMagenta)
	termbox.Flush()
}

func setDroid(to, from complex128) {
	var x, y int
	x = offsetX + int(imag(from))
	y = offsetY + int(real(from))
	termbox.SetCell(x, y, '.', termbox.ColorBlue, termbox.ColorBlack)
	x = offsetX + int(imag(to))
	y = offsetY + int(real(to))
	termbox.SetCell(x, y, 'D', termbox.ColorBlue, termbox.ColorBlack)
	termbox.Flush()
}

func setOxygen(pos complex128) {
	var x, y int
	x = offsetX + int(imag(pos))
	y = offsetY + int(real(pos))
	termbox.SetCell(x, y, 'o', termbox.ColorWhite, termbox.ColorGreen)
	termbox.Flush()
}

type droid struct {
	com intcode.Computer
	pos complex128
	out chan int64
}

func newDroid(code []int) droid {
	ch := make(chan int64)
	com := intcode.New(code)
	com.Output(ch)
	return droid{
		com: com,
		out: ch,
	}
}

func (d *droid) start() {
	err := termbox.Init()
	if err != nil {
		log.Fatal(err)
	}
	defer termbox.Close()

	initScreen()

	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		d.com.RunD9()
		wg.Done()
	}()
	go d.keyboard()
	wg.Wait()
}

func (d *droid) keyboard() {
	for {
		if ev := termbox.PollEvent(); ev.Type == termbox.EventKey {
			switch ev.Key {
			case termbox.KeyArrowUp:
				d.move(north)
			case termbox.KeyArrowDown:
				d.move(south)
			case termbox.KeyArrowLeft:
				d.move(west)
			case termbox.KeyArrowRight:
				d.move(east)
			case termbox.KeyCtrlX:
				fallthrough
			case termbox.KeyCtrlC:
				termbox.Close()
				log.Fatal("exit")
			}
		} else if ev.Type == termbox.EventInterrupt {
			log.Fatal("Terminated")
		}
	}
}

func (d *droid) move(cmd movcmd) (status int) {
	next := d.pos + movdir[cmd]
	go d.com.Input(int(cmd))
	status = int(<-d.out)
	switch status {
	case 0:
		setWall(next)
	case 1:
		setDroid(next, d.pos)
		d.pos = next
	case 2:
		setDroid(next, d.pos)
		d.pos = next
		setOxygen(next)
	}
	return
}

func (d *droid) path(count int, back movcmd, grid gridmap) (result int, target complex128) {
	grid[d.pos] = true
	result = -1
	for cmd, bck := range movback {
		if cmd == back {
			continue
		}
		time.Sleep(delay)
		switch status := d.move(cmd); status {
		case 1:
			step, tgt := d.path(count+1, bck, grid)
			if step > 0 {
				result = step
				target = tgt
			}
		case 2:
			result = count + 1
			target = d.pos
			grid[d.pos] = true
			d.move(bck)
		}
	}
	if back != 0 {
		d.move(back)
	}
	return
}
