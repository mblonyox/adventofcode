package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {

	input, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer input.Close()

	var result1, result2 int64

	scanner := bufio.NewScanner(input)

	for scanner.Scan() {
		mass, err := strconv.ParseInt(scanner.Text(), 10, 64)
		if err != nil {
			log.Fatal(err)
		}
		result1 += findFuel(mass)
		result2 += findReqFuel(mass)
	}

	fmt.Printf("Part 1: %d \r\n", result1)
	fmt.Printf("Part 2: %d \r\n", result2)

}

func findFuel(mass int64) int64 {
	return (mass / 3) - 2
}

func findReqFuel(mass int64) int64 {
	temp := findFuel(mass)
	if temp > 0 {
		return temp + findReqFuel(temp)
	}
	return 0
}
