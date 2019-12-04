package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/briandowns/spinner"
)

func main() {
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

	if len(os.Args) < 2 {
		log.Fatal("Please provide input...")
	}
	input := os.Args[1]
	nums := strings.Split(input, "-")
	if len(nums) < 2 {
		log.Fatal("Please provide maximum range...")
	}
	min, err := strconv.Atoi(nums[0])
	if err != nil {
		log.Fatalf("Min range is not a number: %s", err.Error())
	}
	max, err := strconv.Atoi(nums[1])
	if err != nil {
		log.Fatalf("Max range is not a number: %s", err.Error())
	}

	for i := min; i <= max; i++ {
		r1, r2 := checkPassword(i)
		if r1 {
			result1++
		}
		if r2 {
			result2++
		}
	}

}

func checkPassword(num int) (result1, result2 bool) {
	pass := strconv.Itoa(num)
	// Check length == 6
	// if len(pass) != 6 {
	// 	return
	// }
	// Check within range
	// if num < *min || num > *max {
	// 	return
	// }
	// Check decrease and double
	count := 1
	for i := 0; i < 5; i++ {
		a := pass[i]
		b := pass[i+1]
		if a > b {
			return false, false
		}
		if a == b {
			count++
			result1 = true
		} else {
			if count == 2 {
				result2 = true
			}
			count = 1
		}
	}
	if count == 2 {
		result2 = true
	}
	return
}
