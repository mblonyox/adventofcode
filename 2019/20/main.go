package main

import (
	"fmt"
	"log"
	"strings"

	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

type pos2d struct {
	x, y int
}

type pos3d struct {
	pos2d
	z int
}

func (p pos2d) nexts() []pos2d {
	return []pos2d{
		{p.x, p.y - 1},
		{p.x, p.y + 1},
		{p.x - 1, p.y},
		{p.x + 1, p.y},
	}
}

func (p pos3d) nexts() []pos3d {
	return []pos3d{
		{pos2d{p.x, p.y - 1}, p.z},
		{pos2d{p.x, p.y + 1}, p.z},
		{pos2d{p.x - 1, p.y}, p.z},
		{pos2d{p.x + 1, p.y}, p.z},
	}
}

var grid [][]rune
var tunnels map[pos2d]pos2d
var aa, zz pos2d

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	grid = getGrid()
	tunnels, aa, zz = getTunnels(grid)
	result1 = getResult1()
	result2 = getResult2()
}

func getResult1() (result int) {
	queues := []pos2d{aa}
	seen := map[pos2d]int{aa: 0}

	for len(queues) > 0 {
		current := queues[0]
		queues = queues[1:]
		nexts := current.nexts()
		if p, ok := tunnels[current]; ok {
			nexts = append(nexts, p)
		}
		for _, next := range nexts {
			if next == zz {
				return seen[current] + 1
			}
			if _, ok := seen[next]; ok {
				continue
			}
			if grid[next.y][next.x] != '.' {
				continue
			}
			seen[next] = seen[current] + 1
			queues = append(queues, next)
		}
	}
	return
}

func getResult2() (result int) {

	start := pos3d{aa, 0}
	end := pos3d{zz, 0}
	queues := []pos3d{start}
	seen := map[pos3d]int{start: 0}

	for len(queues) > 0 {
		current := queues[0]
		queues = queues[1:]
		nexts := current.nexts()
		if p, ok := tunnels[current.pos2d]; ok {
			if current.isOuter() {
				if current.z > 0 {
					nexts = append(nexts, pos3d{p, current.z - 1})
				}
			} else {
				nexts = append(nexts, pos3d{p, current.z + 1})
			}
		}
		for _, next := range nexts {
			if next == end {
				return seen[current] + 1
			}
			if _, ok := seen[next]; ok {
				continue
			}
			if grid[next.y][next.x] != '.' {
				continue
			}
			seen[next] = seen[current] + 1
			queues = append(queues, next)
		}
	}
	return
}

func (p pos2d) isOuter() bool {
	return p.y == 2 || p.y == len(grid)-3 || p.x == 2 || p.x == len(grid[p.y])-3
}

func getGrid() [][]rune {
	inputs, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}
	grid := [][]rune{}
	for _, line := range inputs {
		grid = append(grid, []rune(line))
	}
	return grid
}

func getTunnels(grid [][]rune) (tunnels map[pos2d]pos2d, AA, ZZ pos2d) {
	warps := make(map[string]pos2d)
	tunnels = make(map[pos2d]pos2d)
	for i := 2; i < len(grid)-2; i++ {
		for j := 2; j < len(grid[i])-2; j++ {
			pos := pos2d{j, i}
			r := grid[i][j]
			if r != '.' {
				continue
			}
			pairs := []string{
				string(grid[i][j-2 : j]),
				string(grid[i][j+1 : j+3]),
				string([]rune{grid[i-2][j], grid[i-1][j]}),
				string([]rune{grid[i+1][j], grid[i+2][j]}),
			}
			for _, pair := range pairs {
				if strings.ContainsAny(pair, "#. ") {
					continue
				}
				if pair == "AA" {
					AA = pos
					continue
				}
				if pair == "ZZ" {
					ZZ = pos
					continue
				}
				if warp, exist := warps[pair]; exist {
					tunnels[pos] = warp
					tunnels[warp] = pos
					delete(warps, pair)
				} else {
					warps[pair] = pos
				}
			}
		}
	}
	return
}
