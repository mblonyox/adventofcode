package main

import (
	"fmt"
	"log"
	"math/big"
	"strconv"
	"strings"

	"github.com/mblonyox/adventofcode/2019/pkg/tools/parser"
	"github.com/mblonyox/adventofcode/2019/pkg/tools/spinner"
)

func main() {

	var result1, result2 int
	defer spinner.StopSpinner(spinner.CreateSpinner(), func() {
		fmt.Printf("Part 1: %d \r\nPart 2: %d \r\n", result1, result2)
	})

	inputs, err := parser.ParseTextLine()
	if err != nil {
		log.Fatal(err)
	}

	result1 = getResult1(inputs)
	result2 = getResult2(inputs)
}

func getResult1(inputs []string) (result int) {
	l := 10007
	card := 2019
	for _, input := range inputs {
		str := strings.Split(input, " ")
		technique := strings.Join(str[:len(str)-1], " ")
		arg, _ := strconv.Atoi(str[len(str)-1])
		switch technique {
		case "deal into new":
			card = (l - 1) - card
		case "cut":
			card = (card - arg + l) % l
		case "deal with increment":
			card = (card * arg) % l
		}
	}
	return card
}

// Part 2 credit to reddit :
// https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbnkaju/

func getResult2(inputs []string) (result int) {
	mod := big.NewInt(119315717514047)
	repeats := big.NewInt(101741582076661)
	offset, increment := shuffledSequences(inputs, mod, repeats)
	card := getCard(2020, offset, increment, mod)
	return int(card.Int64())
}

func shuffledSequences(inputs []string, mod, repeat *big.Int) (offset, increment *big.Int) {
	offset, increment = big.NewInt(0), big.NewInt(1)
	for _, input := range inputs {
		str := strings.Split(input, " ")
		technique := strings.Join(str[:len(str)-1], " ")
		arg, _ := strconv.Atoi(str[len(str)-1])
		switch technique {
		case "deal into new":
			increment.Mul(increment, big.NewInt(-1))
			increment.Mod(increment, mod)
			offset.Add(offset, increment)
			offset.Mod(offset, mod)
		case "cut":
			offset.Add(offset, new(big.Int).Mul(big.NewInt(int64(arg)), increment))
			offset.Mod(offset, mod)
		case "deal with increment":
			increment.Mul(increment, new(big.Int).ModInverse(big.NewInt(int64(arg)), mod))
			increment.Mod(increment, mod)
		}
	}
	temp := new(big.Int).Exp(increment, repeat, mod)
	temp2 := new(big.Int).Add(big.NewInt(1), new(big.Int).Neg(temp))
	temp3 := new(big.Int).Add(big.NewInt(1), new(big.Int).Neg(increment))
	temp3.Mod(temp3, mod)
	temp3.ModInverse(temp3, mod)
	offset.Mul(offset, temp2)
	offset.Mul(offset, temp3)
	offset.Mod(offset, mod)
	increment = temp
	return
}

func getCard(position int, offset, increment, mod *big.Int) (result *big.Int) {
	pos := big.NewInt(int64(position))
	result = new(big.Int)
	result.Mul(pos, increment)
	result.Add(offset, result)
	result.Mod(result, mod)
	return
}
