package main

import (
	"fmt"
	"log"

	"github.com/mblonyox/adventofcode/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/pkg/tools/spinner"
)

func main() {
	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	input, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}
	result1 = getResult1(input)
	result2 = getResult2(input)

}

type orbit struct {
	name      string
	center    *orbit
	satelites []*orbit
	level     int
}

func (o *orbit) setLevel(base int) {
	o.level = base + 1
	for _, s := range o.satelites {
		s.setLevel(base + 1)
	}
}

func (o *orbit) getCoCenter(q *orbit) *orbit {
	t1 := o
	for t1 != nil {
		t2 := q
		for t2 != nil {
			if t1 == t2 {
				return t1
			}
			t2 = t2.center
		}
		t1 = t1.center
	}
	return nil
}

func mapInput(input []string) (result map[string]*orbit) {
	result = map[string]*orbit{}
	for _, str := range input {
		orb, exist := result[str[4:]]
		if !exist {
			orb = &orbit{
				name:      str[4:],
				satelites: []*orbit{},
			}
		}
		center, exist := result[str[:3]]
		if exist {
			center.satelites = append(center.satelites, orb)
		} else {
			center = &orbit{
				name:      str[:3],
				satelites: []*orbit{orb},
			}
			result[center.name] = center
		}
		orb.center = center
		orb.setLevel(center.level)

		result[orb.name] = orb
	}
	return
}

func getResult1(input []string) (result int) {
	mapOrbit := mapInput(input)
	for _, orb := range mapOrbit {
		result += orb.level
	}
	return
}

func getResult2(input []string) (result int) {
	mapOrbit := mapInput(input)
	you, exist := mapOrbit["YOU"]
	if !exist {
		log.Fatal("YOU not found.")
	}
	san, exist := mapOrbit["SAN"]
	if !exist {
		log.Fatal("SAN not found.")
	}
	co := you.getCoCenter(san)
	if co == nil {
		log.Fatal("No coCenter found")
	}
	return (you.level - co.level) + (san.level - co.level) - 2
}
