package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"time"

	"github.com/briandowns/spinner"
)

func main() {
	startTime := time.Now()
	spin := spinner.New(spinner.CharSets[35], 100*time.Millisecond)
	spin.Suffix = "  : Mohon tunggu"
	spin.Start()
	input, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer input.Close()

	var result1, result2 int

	csvReader := csv.NewReader(input)
	line1, err := csvReader.Read()
	if err != nil {
		log.Fatal(err)
	}
	path1 := createPathMap(line1)
	line2, err := csvReader.Read()
	if err != nil {
		log.Fatal(err)
	}
	path2 := createPathMap(line2)

	result1 = math.MaxInt32
	result2 = math.MaxInt32

	for point, step1 := range path1 {
		if step2, exist := path2[point]; exist {
			if distance := distanceFromCentral(point); distance < result1 {
				result1 = distance
			}
			if steps := step1 + step2; steps < result2 {
				result2 = steps
			}
		}
	}

	spin.Stop()
	fmt.Printf("Part 1: %d \r\n", result1)
	fmt.Printf("Part 2: %d \r\n", result2)
	fmt.Printf("Processing time %s", time.Since(startTime))
}

func createPathMap(line []string) map[complex128]int {
	pathMap := make(map[complex128]int)
	position := 0 + 0i
	step := 0
	for _, move := range line {
		direction := move[0:1]
		distance, err := strconv.ParseInt(move[1:], 10, 64)
		if err != nil {
			log.Fatal(err)
		}
		for i := 0; i < int(distance); i++ {
			switch direction {
			case "U":
				position += 0 + 1i
			case "D":
				position += 0 - 1i
			case "L":
				position += -1 + 0i
			case "R":
				position += 1 + 0i
			}
			step++
			pathMap[position] = step
		}
	}
	return pathMap
}

func calculateDistance(p1, p2 complex128) int {
	return int(math.Abs(real(p1-p2)) + math.Abs(imag(p1-p2)))
}

func distanceFromCentral(point complex128) int {
	return calculateDistance(0+0i, point)
}
