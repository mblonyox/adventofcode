package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/2019/pkg/intcode"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

type packet struct {
	x, y int64
}
type nic struct {
	in, out         chan int64
	queues, outputs []int64
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

	nets := make([]*nic, 50)
	for i := range nets {
		com := intcode.New(code)
		com.Output(make(chan int64))
		in, out := com.IO()
		nets[i] = &nic{in, out, []int64{}, []int64{}}
		go com.RunD9(i)
	}
	res := make(chan int)
	go func() {
		part1 := true
		var idle int
		var isNat bool
		var nat, pre packet
		for {
			allIdle := true
			for _, net := range nets {
				// fmt.Println("queue:", net.queues, "outputs:", net.outputs)
				in := int64(-1)
				if len(net.queues) > 0 {
					in = net.queues[0]
				}
				select {
				case out := <-net.out:
					net.outputs = append(net.outputs, out)
					if len(net.outputs) >= 3 {
						addr := net.outputs[0]
						pkt := packet{net.outputs[1], net.outputs[2]}
						net.outputs[0] = 0
						net.outputs[1] = 0
						net.outputs[2] = 0
						net.outputs = net.outputs[3:]
						if addr == 255 {
							if part1 {
								res <- int(pkt.y)
								part1 = false
							}
							nat = pkt
							isNat = true
						}
						if addr >= 0 && int(addr) < len(nets) {
							nets[addr].queues = append(nets[addr].queues, pkt.x, pkt.y)
						}
					}
					allIdle = false
				case net.in <- in:
					if in != -1 {
						net.queues[0] = 0
						net.queues = net.queues[1:]
						allIdle = false
					}
				}
			}
			if allIdle {
				idle++
			} else {
				idle = 0
			}
			// I don't know what is this constant (5)
			// I guess it's the safe size of input and output bus size
			if idle > 5 {
				if !isNat {
					continue
				}
				if pre == nat {
					res <- int(nat.y)
					return
				}
				nets[0].queues = append(nets[0].queues, nat.x, nat.y)
				isNat = false
				pre = nat
			}
		}
	}()
	result1 = <-res
	result2 = <-res
}
