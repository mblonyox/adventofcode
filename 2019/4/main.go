package main

import (
	"flag"
	"fmt"
	"math"
	"strconv"
	"time"

	"github.com/briandowns/spinner"
)

var min = flag.Int("min", 0, "Minimum range")
var max = flag.Int("max", math.MaxInt32, "Maximum range")

func main() {
	flag.Parse()
	startTime := time.Now()
	var result1, result2 int
	spin := spinner.New(spinner.CharSets[35], 100*time.Millisecond)
	spin.Prefix = "Mohon tunggu~ : "
	spin.Start()

	defer func() {
		spin.Stop()
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
		fmt.Printf("Processing took %s", time.Since(startTime))
	}()

	for i := *min; i <= *max; i++ {
		if checkPassword(i) {
			result1++
			if checkLargestMatch(i) {
				result2++
			}
		}
	}

}

func checkPassword(num int) bool {
	pass := strconv.Itoa(num)
	// Check length == 6
	if len(pass) != 6 {
		return false
	}
	// Check within range
	if num < *min || num > *max {
		return false
	}
	// Check decrease and double
	prev := '0'
	double := false
	for _, d := range pass {
		if d < prev {
			return false
		}
		if d == prev {
			double = true
		}
		prev = d
	}
	return double
}

func checkLargestMatch(num int) bool {
	pass := strconv.Itoa(num)
	prev := '0'
	count := 0
	lastCount := 0
	for _, d := range pass {
		if d == prev {
			count++
		} else {
			if count > 0 {
				lastCount = count
			}
			count = 0
			prev = d
		}
	}
	return lastCount == 1
}
