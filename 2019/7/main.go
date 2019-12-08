package main

import (
	"fmt"
	"log"

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
	result2 = getResult2(code)

	// code = []int{3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26, 27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 0, 0, 5}
	// phase := []int{9, 8, 7, 6, 5}
	// output := 139629729
	// if result := feedbackLoop(code, phase); result != output {
	// 	fmt.Printf("Wrong result. got: %d, want: %d", result, output)
	// }

}

func getResult1(code []int) (result int) {
	phases := permutations([]int{0, 1, 2, 3, 4})
	for _, phase := range phases {
		if signal := amplifiers(code, phase); signal > result {
			result = signal
		}
	}
	return
}

func getResult2(code []int) (result int) {
	phases := permutations([]int{5, 6, 7, 8, 9})
	for _, phase := range phases {
		if signal := feedbackLoop(code, phase); signal > result {
			result = signal
		}
	}
	return
}

func amplifiers(code, phase []int) (output int) {
	input := 0
	for _, p := range phase {
		com := intcode.New(code)
		output = com.RunD5P2(p, input)
		input = output
	}
	return
}

func feedbackLoop(code, phase []int) (output int) {
	amps := make([]intcode.Computer, len(phase))
	for i, p := range phase {
		amps[i] = intcode.New(code)
		amps[i].Input(p)
		if i > 0 {
			amps[i].Listen(&amps[i-1])
		}
		defer amps[i].Close()
	}
	amps[0].Listen(&amps[len(amps)-1])
	amps[0].Input(0)

	ch := make(chan int)
	for i, amp := range amps {
		if i == len(amps)-1 {
			go func(c intcode.Computer) {
				ch <- c.RunD5P2()
				close(ch)
			}(amp)
		} else {
			go func(c intcode.Computer) {
				c.RunD5P2()
			}(amp)
		}
	}
	return <-ch
}

// This code is not mine; credit to https://stackoverflow.com/a/30226442
func permutations(arr []int) [][]int {
	var helper func([]int, int)
	res := [][]int{}

	helper = func(arr []int, n int) {
		if n == 1 {
			tmp := make([]int, len(arr))
			copy(tmp, arr)
			res = append(res, tmp)
		} else {
			for i := 0; i < n; i++ {
				helper(arr, n-1)
				if n%2 == 1 {
					tmp := arr[i]
					arr[i] = arr[n-1]
					arr[n-1] = tmp
				} else {
					tmp := arr[0]
					arr[0] = arr[n-1]
					arr[n-1] = tmp
				}
			}
		}
	}
	helper(arr, len(arr))
	return res
}
