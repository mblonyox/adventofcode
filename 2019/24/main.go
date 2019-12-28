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
	result2 = getResult2(input)
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
	return calcRating(input)
}

func getResult2(input []byte) (result int) {
	input[14] = '?'
	emptyLevel := ".....\n.....\n..?..\n.....\n....."
	neighbours := map[string]int{
		"top":    -6,
		"left":   -1,
		"right":  1,
		"bottom": 6,
	}
	levels := map[int]string{0: string(input)}
	for i := 1; i < 101; i++ {
		levels[i] = emptyLevel
		levels[-i] = emptyLevel
	}
	for i := 0; i < 200; i++ {
		tmpLevels := map[int]string{}
		for j, layout := range levels {
			tmpLayout := []byte(layout)
			for k, b := range tmpLayout {
				if b == '?' {
					continue
				}
				count := 0
				for pos, n := range neighbours {
					p := k + n
					if p < 0 || p >= len(layout) || layout[p] == '\n' {
						outer, ok := levels[j-1]
						if ok && outer[14+n] == '#' {
							count++
						}
						continue
					}
					if layout[p] == '?' {
						inner, ok := levels[j+1]
						if ok {
							var edge []int
							switch pos {
							case "bottom":
								edge = []int{0, 1, 2, 3, 4}
							case "right":
								edge = []int{0, 6, 12, 18, 24}
							case "left":
								edge = []int{4, 10, 16, 22, 28}
							case "top":
								edge = []int{24, 25, 26, 27, 28}
							}
							for _, o := range edge {
								if inner[o] == '#' {
									count++
								}
							}
						}
						continue
					}
					if layout[p] == '#' {
						count++
					}
				}
				if b == '#' && count != 1 {
					tmpLayout[k] = '.'
				} else if b == '.' && (count == 1 || count == 2) {
					tmpLayout[k] = '#'
				}
			}
			tmpLevels[j] = string(tmpLayout)
		}
		levels = tmpLevels
	}
	for _, level := range levels {
		for _, r := range level {
			if r == '#' {
				result++
			}
		}
	}
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
