package main

import (
	"testing"
)

func TestCheckPassword(t *testing.T) {

	min = 111111
	max = 888888

	type testCase struct {
		input       int
		result1     bool
		result2     bool
		description string
	}

	testCase1 := []testCase{
		{
			input:       111111,
			result1:     true,
			result2:     false,
			description: "111111 meets these criteria (double 11, never decreases).",
		},
		{
			input:       223450,
			result1:     false,
			result2:     false,
			description: "223450 does not meet these criteria (decreasing pair of digits 50).",
		},
		{
			input:       123789,
			result1:     false,
			result2:     false,
			description: "123789 does not meet these criteria (no double).",
		},
		{
			input:       111110,
			result1:     false,
			result2:     false,
			description: "111110 is below the min range provided (111111).",
		},
		{
			input:       888889,
			result1:     false,
			result2:     false,
			description: "111110 is above the max range provided (888888).",
		},
		{
			input:       1234567,
			result1:     false,
			result2:     false,
			description: "1234567 is above 6 digits.",
		},
	}

	t.Run("Part 1", func(t *testing.T) {
		for _, test := range testCase1 {
			if result1, _ := checkPassword(test.input); result1 != test.result1 {
				t.Errorf("Result wrong, got: %t, want: %t. \r\nDescription: %s", result1, test.result1, test.description)
			}
		}
	})

	testCase2 := []testCase{
		{
			input:       112233,
			result1:     true,
			result2:     true,
			description: "112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.",
		},
		{
			input:       123444,
			result1:     true,
			result2:     false,
			description: "123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).",
		},
		{
			input:       111122,
			result1:     true,
			result2:     true,
			description: "111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).",
		},
	}

	t.Run("Part 2", func(t *testing.T) {
		for _, test := range testCase2 {
			if _, result2 := checkPassword(test.input); result2 != test.result2 {
				t.Errorf("Result wrong, got: %t, want: %t. \r\nDescription: %s", result2, test.result2, test.description)
			}
		}
	})

}

func TestParseArg(t *testing.T) {
	if _, _, err := parseArg([]string{"main.exe"}); err == nil {
		t.Error("no argument provided should be error")
	}

	if _, _, err := parseArg([]string{"main.exe", "21412"}); err == nil {
		t.Error("argument should contain '-' separator")
	}

	if _, _, err := parseArg([]string{"main.exe", "qwedsa-111111"}); err == nil {
		t.Error("invalid min range number in argument")
	}

	if _, _, err := parseArg([]string{"main.exe", "111111-qwesda"}); err == nil {
		t.Error("invalid min range number in argument")
	}

	min, max, err := parseArg([]string{"main.exe", "111111-999999"})
	if err != nil {
		t.Errorf("unexpected error : %s", err.Error())
	}
	if min != 111111 {
		t.Errorf("wrong min range result, got: %d, want: %d", min, 111111)
	}
	if max != 999999 {
		t.Errorf("wrong max range result, got: %d, want: %d", max, 999999)
	}
}
