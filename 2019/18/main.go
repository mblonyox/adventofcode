package main

import (
	"fmt"
	"log"
	"math"
	"sort"
	"strings"
	"unicode"

	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

var tunnels = [][]rune{}
var items = map[rune]position{}

func init() {
	inputs, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}
	for _, line := range inputs {
		tunnels = append(tunnels, []rune(line))
	}
	for i, row := range tunnels {
		for j, cell := range row {
			if cell != '.' && cell != '#' {
				items[cell] = position{j, i}
			}
		}
	}
}

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	result1 = getResult1()
	result2 = getResult2()
}

func getResult1() (result int) {
	start := items['@']
	memo := memoize{}
	return shortest(start, "", memo)
}

func getResult2() (result int) {
	return
}

type position struct{ x, y int }

type direction position

var (
	up         = direction{-1, 0}
	down       = direction{1, 0}
	left       = direction{0, -1}
	right      = direction{0, 1}
	directions = []direction{up, down, left, right}
)

func (p position) valid() bool {
	return p.x >= 0 && p.x < len(tunnels[0]) && p.y >= 0 && p.y < len(tunnels)
}

func (p position) nextTo(d direction) position {
	return position{p.x + d.x, p.y + d.y}
}

func (p position) reachable(collected string) (keyDistance map[rune]int) {
	queues := []position{p}
	distance := map[position]int{p: 0}
	keyDistance = map[rune]int{}
	for len(queues) > 0 {
		current := queues[0]
		queues = queues[1:]
		for _, dir := range directions {
			next := current.nextTo(dir)
			if _, prev := distance[next]; prev {
				continue
			}
			if !next.valid() {
				continue
			}
			r := tunnels[next.y][next.x]
			if r == '#' {
				continue
			}
			distance[next] = distance[current] + 1
			if unicode.IsUpper(r) && !strings.ContainsRune(collected, unicode.ToLower(r)) {
				continue
			}
			if unicode.IsLower(r) && !strings.ContainsRune(collected, r) {
				keyDistance[r] = distance[next]
			} else {
				queues = append(queues, next)
			}
		}
	}
	return
}

type memoize map[struct {
	p position
	k string
}]int

func shortest(from position, collected string, memo memoize) (result int) {
	collected = sortString(collected)
	if result, seen := memo[struct {
		p position
		k string
	}{from, collected}]; seen {
		return result
	}
	keys := from.reachable(collected)
	if len(keys) == 0 {
		result = 0
	} else {
		result = math.MaxInt32
		for key, dist := range keys {
			temp := dist + shortest(items[key], collected+string(key), memo)
			if temp < result {
				result = temp
			}
		}
	}
	memo[struct {
		p position
		k string
	}{from, collected}] = result
	return
}

func sortString(s string) string {
	runes := []rune(s)
	sort.SliceStable(runes, func(i, j int) bool {
		return runes[i] < runes[j]
	})
	return string(runes)
}
