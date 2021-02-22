package main

import (
	"testing"
)

func TestGrabFields(t *testing.T) {
	
	output, _ := GrabFields("[{\"cat\": 5, \"dog\": 20}]")
	t.Log(output)
   	/*
    if total != 10 {
       t.Errorf("Sum was incorrect, got: %d, want: %d.", total, 10)
    }
    */


    
}

func TestGenerateSetListing(t *testing.T) {
	output := GenerateSetListing([]string{"cow", "pig", "chicken"})
	t.Log(output)
	if output == "" {
		t.Error("Got empty string")
	}

}