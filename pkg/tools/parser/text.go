package parser

import (
	"bufio"
	"os"
)

// ParseTextLine parse the input.txt into slice of string
func ParseTextLine() (result []string, err error) {
	input, err := os.Open("input.txt")
	if err != nil {
		return
	}
	defer input.Close()
	result = []string{}
	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		result = append(result, scanner.Text())
	}
	return
}
