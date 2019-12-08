package parser

import (
	"encoding/csv"
	"os"
	"strconv"
	"strings"
)

// ParseIntCsv parse the input.txt into slice of int
func ParseIntCsv() (result []int, err error) {
	record, err := ParseCsvInput()
	if err != nil {
		return
	}
	result, err = MapAtoi(record)
	return
}

//MapAtoi map the strconv.Atoi function to slice of strings
func MapAtoi(record []string) (result []int, err error) {
	result = make([]int, len(record))
	for i, s := range record {
		result[i], err = strconv.Atoi(s)
		if err != nil {
			return
		}
	}
	return
}

// ParseCsvInput parse the input.txt into slice of string
func ParseCsvInput() (result []string, err error) {
	input, err := os.Open("input.txt")
	if err != nil {
		return
	}
	defer input.Close()
	csvReader := csv.NewReader(input)
	result, err = csvReader.Read()
	return
}

// ParseCsvString parse the string into slice of string
func ParseCsvString(s string) (result []string, err error) {
	csvReader := csv.NewReader(strings.NewReader(s))
	result, err = csvReader.Read()
	return
}
