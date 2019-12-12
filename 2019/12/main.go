package main

import (
	"fmt"
	"log"
	"regexp"
	"strconv"

	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	lines, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}

	moons := [4]moon{}

	re := regexp.MustCompile(`<x=(-?\d+), y=(-?\d+), z=(-?\d+)>`)
	for i, line := range lines {
		match := re.FindStringSubmatch(line)
		x, _ := strconv.Atoi(match[1])
		y, _ := strconv.Atoi(match[2])
		z, _ := strconv.Atoi(match[3])
		moons[i] = moon{
			pos: position{
				x,
				y,
				z,
			},
		}
	}

	result1 = getResult1(moons)
	result2 = getResult2(moons)
}

func getResult1(moons [4]moon) (result int) {
	// time steps
	for i := 0; i < 1000; i++ {
		// loop each moon
		for j := 0; j < 4; j++ {
			for k := 1; k < 4; k++ {
				moons[j].applyGravity(moons[(j+k)%4])
			}
		}
		for j := 0; j < 4; j++ {
			moons[j].applyVelocity()
		}
	}

	for i := 0; i < 4; i++ {
		result += moons[i].energy()
	}
	return
}

func getResult2(moons [4]moon) (result int) {

	xs := [4]int{}
	ys := [4]int{}
	zs := [4]int{}
	for i, m := range moons {
		xs[i] = m.pos.x
		ys[i] = m.pos.y
		zs[i] = m.pos.z
	}
	rx := revolution(xs)
	ry := revolution(ys)
	rz := revolution(zs)
	return LCM(rx, ry, rz)
}

func absInt(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

type position struct {
	x,
	y,
	z int
}

func (pos *position) potential() int {
	return absInt(pos.x) + absInt(pos.y) + absInt(pos.z)
}

type velocity position

func (vel *velocity) kinetic() int {
	return absInt(vel.x) + absInt(vel.y) + absInt(vel.z)
}

type moon struct {
	pos position
	vel velocity
}

func (m *moon) applyGravity(n moon) {
	if n.pos.x > m.pos.x {
		m.vel.x++
	} else if n.pos.x < m.pos.x {
		m.vel.x--
	}
	if n.pos.y > m.pos.y {
		m.vel.y++
	} else if n.pos.y < m.pos.y {
		m.vel.y--
	}
	if n.pos.z > m.pos.z {
		m.vel.z++
	} else if n.pos.z < m.pos.z {
		m.vel.z--
	}
}

func (m *moon) applyVelocity() {
	m.pos.x += m.vel.x
	m.pos.y += m.vel.y
	m.pos.z += m.vel.z
}

func (m *moon) energy() int {
	return m.pos.potential() * m.vel.kinetic()
}

func revolution(ori [4]int) (result int) {
	pos := [4]int{}
	for i, n := range ori {
		pos[i] = n
	}
	vel := [4]int{}
	for {
		for i := 0; i < 4; i++ {
			for j := 0; j < 4; j++ {
				if i == j {
					continue
				}
				if pos[i] < pos[j] {
					vel[i]++
				} else if pos[i] > pos[j] {
					vel[i]--
				}
			}
		}
		for i := 0; i < 4; i++ {
			pos[i] += vel[i]
		}
		result++
		if pos == ori && vel == [4]int{} {
			return
		}
	}
}

/**
 ** Credit to https://siongui.github.io/2017/06/03/go-find-lcm-by-gcd/
 **/

//GCD greatest common divisor via Euclidean algorithm
func GCD(a, b int) int {
	for b != 0 {
		t := b
		b = a % b
		a = t
	}
	return a
}

//LCM find Least Common Multiple via GCD
func LCM(a, b int, integers ...int) int {
	result := a * b / GCD(a, b)

	for i := 0; i < len(integers); i++ {
		result = LCM(result, integers[i])
	}

	return result
}
