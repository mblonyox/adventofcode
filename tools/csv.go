package tools

import (
	"encoding/csv"
	"os"
	"strconv"
)

// ParseIntCsv parse the input.txt into slice of int
func ParseIntCsv() (result []int, err error) {
	input, err := os.Open("input.txt")
	if err != nil {
		return
	}
	defer input.Close()
	csvReader := csv.NewReader(input)
	record, err := csvReader.Read()
	if err != nil {
		return
	}
	result = make([]int, len(record))
	for i, s := range record {
		result[i], err = strconv.Atoi(s)
		if err != nil {
			return
		}
	}
	return
}
