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
	ftm := fromToMovement{}
	start := items['@']
	start.search(ftm)
	for r, item := range items {
		if unicode.IsLower(r) {
			item.search(ftm)
		}
	}
	return shortest([]position{start}, "", ftm, map[string]int{})
}

func getResult2() (result int) {
	ftm := fromToMovement{}
	origin := items['@']
	tunnels[origin.y][origin.x] = '#'
	for _, dir := range directions {
		tunnels[origin.y+dir.y][origin.x+dir.x] = '#'
	}
	starts := []position{
		{origin.x + 1, origin.y - 1},
		{origin.x + 1, origin.y + 1},
		{origin.x - 1, origin.y + 1},
		{origin.x - 1, origin.y - 1},
	}
	for _, start := range starts {
		start.search(ftm)
	}
	for r, item := range items {
		if unicode.IsLower(r) {
			item.search(ftm)
		}
	}
	return shortest(starts, "", ftm, map[string]int{})
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

type movement struct {
	key rune
	from,
	to position
	distance int
	doors    string
}

type fromToMovement map[position]map[position]movement

func (ftm fromToMovement) reachable(from position, haveKeys string) []movement {
	result := []movement{}
outer:
	for _, m := range ftm[from] {
		if strings.ContainsRune(haveKeys, m.key) {
			continue outer
		}
		for _, d := range m.doors {
			if !strings.ContainsRune(haveKeys, unicode.ToLower(d)) {
				continue outer
			}
		}
		result = append(result, m)
	}
	return result
}

func (p position) search(ftm fromToMovement) {
	ftm[p] = map[position]movement{}
	distance := map[position]int{p: 0}
	type queue struct {
		p     position
		doors string
	}
	queues := []queue{{p: p}}
	for len(queues) > 0 {
		current := queues[0]
		queues = queues[1:]
		for _, dir := range directions {
			next := current.p.nextTo(dir)
			doors := current.doors
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
			distance[next] = distance[current.p] + 1
			if unicode.IsUpper(r) && !strings.ContainsRune(doors, r) {
				doors += string(r)
			}
			if unicode.IsLower(r) {
				if _, exist := ftm[p][next]; !exist {
					ftm[p][next] = movement{
						key:      r,
						from:     p,
						to:       next,
						distance: distance[next],
						doors:    doors,
					}
				}
			}
			queues = append(queues, queue{next, doors})
		}
	}
	return
}

func shortest(starts []position, haveKeys string, ftm fromToMovement, memo map[string]int) (result int) {
	haveKeys = sortString(haveKeys)
	mKey := fmt.Sprint(starts, haveKeys)
	if result, seen := memo[mKey]; seen {
		return result
	}
	options := []movement{}
	for _, start := range starts {
		options = append(options, ftm.reachable(start, haveKeys)...)
	}
	if len(options) == 0 {
		result = 0
	} else {
		result = math.MaxInt32
		for _, m := range options {
			nextStarts := make([]position, len(starts))
			for i, start := range starts {
				if start == m.from {
					nextStarts[i] = m.to
				} else {
					nextStarts[i] = start
				}
			}
			temp := m.distance + shortest(nextStarts, haveKeys+string(m.key), ftm, memo)
			if temp < result {
				result = temp
			}
		}
	}
	memo[mKey] = result
	return
}

func sortString(s string) string {
	runes := []rune(s)
	sort.SliceStable(runes, func(i, j int) bool {
		return runes[i] < runes[j]
	})
	return string(runes)
}
