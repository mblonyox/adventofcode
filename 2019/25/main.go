package main

import (
	"bufio"
	"fmt"
	"log"
	"os"

	"github.com/mblonyox/adventofcode/2019/pkg/intcode"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
)

func main() {

	var result1, result2 int
	defer func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	}()

	code, err := parser.ParseIntCsv()
	if err != nil {
		log.Fatal(err)
	}
	out := make(chan int64)
	com := intcode.New(code)
	com.Output(out)
	go func() {
		for {
			fmt.Print(string(<-out))
		}
	}()
	go com.RunD9()
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		command := scanner.Text()
		command += "\n"
		input := make([]int, len(command))
		for i, b := range []byte(command) {
			input[i] = int(b)
		}
		com.Input(input...)
	}
}

func getResult1() (result int) {
	return
}

func getResult2() (result int) {
	return
}
