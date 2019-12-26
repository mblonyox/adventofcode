package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"

	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	input, err := ioutil.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	result1 = getResult1(input)
	result2 = getResult2()
}

func getResult1(input []byte) (result int) {
	memo := map[string]int{}
	for i := 0; ; i++ {
		memo[string(input)] = i
		tmp := make([]byte, len(input))
		for j := 0; j < len(input); j++ {
			adj := getAdjBugs(input, j)
			if input[j] == '#' && adj != 1 {
				tmp[j] = '.'
			} else if input[j] == '.' && (adj == 1 || adj == 2) {
				tmp[j] = '#'
			} else {
				tmp[j] = input[j]
			}
		}
		input = tmp
		if _, ok := memo[string(input)]; ok {
			break
		}
	}
	// fmt.Println(string(input))
	return calcRating(input)
}

func getResult2() (result int) {
	return
}

func getAdjBugs(s []byte, i int) (result int) {
	for _, n := range []int{-6, -1, 1, 6} {
		n += i
		if n < 0 || n >= len(s) {
			continue
		}
		if s[n] == '#' {
			result++
		}
	}
	return
}

func calcRating(input []byte) (result int) {
	s := strings.ReplaceAll(string(input), "\n", "")
	for i, n := 0, 1; i < len(s); i, n = i+1, n*2 {
		if s[i] == '#' {
			result += n
		}
	}
	return
}
