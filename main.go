package main

import (
	"log"

	"github.com/nicholasjackson/gopher-search/gopher_search/actions"
)

func main() {
	app := actions.App()
	if err := app.Serve(); err != nil {
		log.Fatal(err)
	}
}
