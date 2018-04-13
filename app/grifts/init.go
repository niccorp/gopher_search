package grifts

import (
	"github.com/gobuffalo/buffalo"
	"github.com/nicholasjackson/gopher-search/gopher_search/actions"
)

func init() {
	buffalo.Grifts(actions.App())
}
