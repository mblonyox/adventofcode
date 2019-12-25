package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/pkg/2019/intcode"
	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

type packet struct {
	x, y int64
}
type nic struct {
	in, out chan int64
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

	nets := make([]nic, 50)
	for i := range nets {
		com := intcode.New(code)
		com.Output(make(chan int64))
		in, out := com.IO()
		nets[i] = nic{in, out}
		go com.RunD9(i)
	}
	res := make(chan int)
	go func() {
		part1 := true
		for {
			for _, net := range nets {
				select {
				case addr := <-net.out:
					pkt := packet{<-net.out, <-net.out}
					// fmt.Println("packet to:", addr, pkt)
					if addr == 255 {
						if part1 {
							res <- int(pkt.y)
							part1 = false
						}
					}
					if addr >= 0 && int(addr) < len(nets) {
						nets[addr].in <- pkt.x
						nets[addr].in <- pkt.y
					}
				case net.in <- -1:
				}
			}
		}
	}()
	result1 = <-res
	// result2 = <-res
}
