package main

import (
	"flag"
	"log"

	"github.com/nicholasjackson/gopher-search/gopher_search/actions"
)

var tlsCert = flag.String("tls_cert", "", "")
var tlsKey = flag.String("tls_key", "", "")

func main() {
	flag.Parse()

	app := actions.App()
	if err := app.Serve(*tlsKey, *tlsCert); err != nil {
		log.Fatal(err)
	}
}
