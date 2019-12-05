package tools

import (
	"fmt"
	"time"

	"github.com/briandowns/spinner"
)

// Spinner is structured data containing the Spinner and the time it start spinning
type Spinner struct {
	*spinner.Spinner
	TimeStart time.Time
}

// CreateSpinner do create a Spinner instance with pre configured
func CreateSpinner() Spinner {
	s := Spinner{
		spinner.New(spinner.CharSets[54], 200*time.Millisecond),
		time.Now(),
	}
	s.Prefix = "Mohon tunggu~ : "
	s.Start()
	return s
}

// StopSpinner do stop the Spinner instance and print the elapsed time
func StopSpinner(s Spinner, f func()) {
	s.Stop()
	if f != nil {
		f()
	}
	fmt.Printf("Processing took %s", time.Since(s.TimeStart))
}
