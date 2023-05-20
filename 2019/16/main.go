package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"

	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

var pattern = []int{1, 0, -1, 0}

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	inputs, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}

	result1 = getResult1(inputs[0])
	result2 = getResult2(inputs[0])
}

func getResult1(s string) (result int) {
	f := newFft(s)
	for i := 0; i < 100; i++ {
		f.phase()
	}
	result = f.toInt(0, 8)
	return
}

func getResult2(s string) (result int) {
	s = strings.Repeat(s, 10000)
	f := newFft(s)
	offset := f.toInt(0, 7)
	f = f[offset:]
	for i := 0; i < 100; i++ {
		f.phase2()
	}
	result = f.toInt(0, 8)
	return
}

type fft []int

func (f *fft) phase() {
	v := *f
	result := make(fft, len(v))
	for i := 0; i < len(v); i++ {
		temp := 0
		for j, num := range v[i:] {
			temp += num * pattern[(j/(i+1))%4]
		}
		result[i] = abs(temp) % 10
	}
	*f = result
	return
}

func (f *fft) phase2() {
	s := f.sum()
	for i := 0; i < len(*f); i++ {
		t := (*f)[i]
		(*f)[i] = s % 10
		s -= t
	}
}

func (f fft) sum() (result int) {
	for _, n := range f {
		result += n
	}
	return
}

func (f fft) toString(start, end int) (result string) {
	for _, num := range f[start:end] {
		result += strconv.Itoa(num)
	}
	return
}

func (f fft) toInt(start, end int) (result int) {
	result, _ = strconv.Atoi(f.toString(start, end))
	return
}

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func newFft(s string) fft {
	result := make(fft, len([]rune(s)))
	for i, num := range s {
		result[i], _ = strconv.Atoi(string(num))
	}
	return result
}
