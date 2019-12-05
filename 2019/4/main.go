package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/mblonyox/adventofcode/tools"
)

var min, max int
var result1, result2 int

func main() {
	var err error
	min, max, err = parseArg(os.Args)
	if err != nil {
		log.Fatal(err)
	}

	defer tools.StopSpinner(tools.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

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

func parseArg(args []string) (min, max int, err error) {

	if len(args) < 2 {
		err = fmt.Errorf("no arguments provided")
		return
	}
	input := args[1]
	nums := strings.Split(input, "-")
	if len(nums) < 2 {
		err = fmt.Errorf("invalid argument")
		return
	}
	min, err = strconv.Atoi(nums[0])
	if err != nil {
		err = fmt.Errorf("failed to parse min range: %s", err.Error())
		return
	}
	max, err = strconv.Atoi(nums[1])
	if err != nil {
		err = fmt.Errorf("failed to parse max rang: %s", err.Error())
		return
	}
	return
}

func checkPassword(num int) (result1, result2 bool) {
	pass := strconv.Itoa(num)
	// Check length == 6
	if len(pass) != 6 {
		return
	}
	// Check within range
	if num < min || num > max {
		return
	}
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
