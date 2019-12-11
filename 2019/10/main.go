package main

import (
	"fmt"
	"log"
	"sort"

	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	input, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}

	asteroids := parseAsteroids(input)

	result1 = getResult1(asteroids)
	result2 = getResult2(asteroids)
}

func getResult1(asteroids []complex128) (result int) {
	angles := getBestLocation(asteroids)
	return len(angles)
}

func getResult2(asteroids []complex128) (result int) {
	angles := getBestLocation(asteroids)
	twoHundredth := get200thAsteroid(angles)
	result = int(real(twoHundredth))*100 + int(imag(twoHundredth))
	return
}

func parseAsteroids(s []string) (result []complex128) {
	result = []complex128{}
	for y, r := range s {
		for x, c := range r {
			if c == '#' {
				result = append(result, complex(float64(x), float64(y)))
			}
		}
	}
	return
}

func getBestLocation(asteroids []complex128) (result map[float64][]complex128) {
	highest := 0
	for _, pos := range asteroids {
		angles := detectAsteroids(asteroids, pos)
		if len(angles) > highest {
			highest = len(angles)
			result = angles
		}
	}
	return
}

func detectAsteroids(asteroids []complex128, position complex128) map[float64][]complex128 {
	angles := map[float64][]complex128{}

	for _, asteroid := range asteroids {
		if asteroid == position {
			continue
		}
		angle := diamondAngle(position, asteroid)
		if _, ok := angles[angle]; ok {
			angles[angle] = append(angles[angle], asteroid)
			continue
		}
		angles[angle] = []complex128{asteroid}
	}

	return angles
}

func diamondAngle(pos1, pos2 complex128) float64 {
	x := real(pos2) - real(pos1)
	y := imag(pos2) - imag(pos1)

	if x >= 0 {
		// 1st kuadran top right
		if y < 0 {
			return x / (x - y)
		}
		// 2nd kuadran bottom right
		return 1 + (y / (x + y))
	}
	// 3rd kuadran bottom left
	if y >= 0 {
		return 2 + (x / (x - y))
	}
	// 4th kuadran top left
	return 3 + (y / (x + y))
}

func get200thAsteroid(angles map[float64][]complex128) (result complex128) {
	keys := make([]float64, 0, len(angles))
	for k := range angles {
		keys = append(keys, k)
	}

	sort.Float64s(keys)

	i := 1

	for len(angles) > 0 {
		for _, k := range keys {
			if asteroids, ok := angles[k]; ok {
				if i == 200 {
					return asteroids[0]
				}
				angles[k] = asteroids[1:]
				i++
				if len(angles[k]) == 0 {
					delete(angles, k)
				}
			}
		}
	}

	return
}
