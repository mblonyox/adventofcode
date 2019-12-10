package main

import (
	"fmt"
	"testing"
)

func TestBoost(t *testing.T) {
	t.Run("quine", func(t *testing.T) {
		code := []int{109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99}
		outputs := boost(code)
		for i, n := range outputs {
			if int(n) != code[i] {
				t.Error("wrong output, not copy of itself")
				return
			}
		}
	})

	t.Run("16-digit number", func(t *testing.T) {
		code := []int{1102, 34915192, 34915192, 7, 4, 7, 99, 0}
		outputs := boost(code)
		output := outputs[len(outputs)-1]
		if len(fmt.Sprint(output)) != 16 {
			t.Errorf("output is not 16-digit number. got: %d", output)
		}
	})

	t.Run("large number", func(t *testing.T) {
		code := []int{104, 1125899906842624, 99}
		outputs := boost(code)
		output := outputs[len(outputs)-1]
		if output != 1125899906842624 {
			t.Errorf("output is not 1125899906842624. got: %d", output)
		}
	})
}
