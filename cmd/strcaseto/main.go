// Copyright (c) 2023  The Go-Curses Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/iancoleman/strcase"
	"github.com/urfave/cli/v2"

	clcli "github.com/go-corelibs/cli"
)

var (
	BuildVersion = "0.2.0"
	BuildRelease = "trunk"
)

var gBaseName string

func init() {
	gBaseName = filepath.Base(os.Args[0])

	cli.HelpFlag = &cli.BoolFlag{
		Category: "General",
		Name:     "help",
		Aliases:  []string{"h", "usage"},
	}

	cli.VersionFlag = &cli.BoolFlag{
		Category: "General",
		Name:     "version",
		Aliases:  []string{"V"},
	}

	cli.FlagStringer = clcli.NewFlagStringer().
		PruneDefaultBools(true).
		DetailsOnNewLines(true).
		Make()
}

var (
	gModeInfo = map[string]struct {
		fn      func(input string) (output string)
		example string
	}{
		"camel":           {fn: strcase.ToCamel, example: "CamelCase"},
		"lower-camel":     {fn: strcase.ToLowerCamel, example: "lowerCamelCase"},
		"kebab":           {fn: strcase.ToKebab, example: "kebab-case"},
		"screaming-kebab": {fn: strcase.ToScreamingKebab, example: "SCREAMING-KEBAB-CASE"},
		"snake":           {fn: strcase.ToSnake, example: "snake_case"},
		"screaming-snake": {fn: strcase.ToScreamingSnake, example: "SCREAMING_SNAKE_CASE"},
	}
)

func main() {

	var err error
	var cliFlags []cli.Flag
	var fn func(string) string
	var name, usage, usageText, description string

	checkName := gBaseName
	for _, prefix := range []string{"strcaseto-", "strto-", "to-"} {
		if strings.HasPrefix(checkName, prefix) {
			checkName = checkName[len(prefix):]
			break
		}
	}
	checkName = strings.TrimSuffix(checkName, "-case")

	if info, ok := gModeInfo[checkName]; ok {

		// program is symlinked to a specific strcase
		name = gBaseName + " (strcaseto)"
		fn = info.fn
		usage = "convert strings to " + info.example
		usageText = gBaseName +
			" <string> [string...]\n" +
			"echo \"one-or-more-lines\" | " +
			gBaseName
		description = "" +
			"Convert command line arguments (or lines of os.Stdin) to " + info.example + ".\n" +
			"Outputting one line of text per input given."

	} else {

		// program is used directly, allow all strcases
		name = "strcaseto"
		usage = "convert strings to various cases"
		usageText = gBaseName +
			" [option] <string> [string...]\n" +
			"echo \"one-or-more-lines\" | " +
			gBaseName +
			" [option]"
		description = "" +
			"Convert command line arguments (or lines of os.Stdin) to a specific case.\n" +
			"Outputting one line of text per input given."
		cliFlags = append(cliFlags,
			&cli.BoolFlag{Category: "Cases", Name: "camel", Aliases: []string{"c"}},
			&cli.BoolFlag{Category: "Cases", Name: "lower-camel", Aliases: []string{"C"}},
			&cli.BoolFlag{Category: "Cases", Name: "kebab", Aliases: []string{"k"}},
			&cli.BoolFlag{Category: "Cases", Name: "screaming-kebab", Aliases: []string{"K"}},
			&cli.BoolFlag{Category: "Cases", Name: "snake", Aliases: []string{"s"}},
			&cli.BoolFlag{Category: "Cases", Name: "screaming-snake", Aliases: []string{"S"}},
		)
	}

	app := &cli.App{
		Name:            name,
		Version:         BuildVersion + " (" + BuildRelease + ")",
		Usage:           usage,
		UsageText:       usageText,
		Description:     description,
		HideHelpCommand: true,
		Flags:           cliFlags,
		Action: func(ctx *cli.Context) error {
			return action(ctx, fn)
		},
	}

	if err = app.Run(os.Args); err != nil {
		fatal("error: %v\n", err)
	}
}

func parseActionInputs(ctx *cli.Context) (inputs []string) {
	if ctx.Bool("help") {
		cli.ShowAppHelpAndExit(ctx, 0)
	} else if ctx.Bool("version") {
		cli.ShowVersion(ctx)
		return
	} else if ctx.NArg() > 0 {
		inputs = ctx.Args().Slice()
	} else if stat, ee := os.Stdin.Stat(); ee == nil && stat.Mode()&os.ModeCharDevice == 0 {
		if data, ee := io.ReadAll(os.Stdin); ee == nil && len(data) > 0 {
			raw := string(data)
			raw = strings.ReplaceAll(raw, "\r", "")
			if last := len(raw) - 1; raw[last] == '\n' {
				raw = raw[:last]
			}
			inputs = strings.Split(raw, "\n")
		}
	} else {
		cli.ShowAppHelpAndExit(ctx, 0)
	}
	return
}

func action(ctx *cli.Context, fn func(string) string) (err error) {
	var outputs []string
	inputs := parseActionInputs(ctx)

	if fn != nil {
		outputs = convert(fn, inputs...)
	} else if ctx.Bool("screaming-kebab") {
		outputs = convert(strcase.ToScreamingKebab, inputs...)
	} else if ctx.Bool("screaming-snake") {
		outputs = convert(strcase.ToScreamingSnake, inputs...)
	} else if ctx.Bool("lower-camel") {
		outputs = convert(strcase.ToLowerCamel, inputs...)
	} else if ctx.Bool("camel") {
		outputs = convert(strcase.ToCamel, inputs...)
	} else if ctx.Bool("kebab") {
		outputs = convert(strcase.ToKebab, inputs...)
	} else if ctx.Bool("snake") {
		outputs = convert(strcase.ToSnake, inputs...)
	} else {
		outputs = convert(strcase.ToCamel, inputs...)
	}

	switch len(outputs) {
	case 0:
		cli.ShowAppHelpAndExit(ctx, 1)
	case 1:
		stdout("%v", outputs[0])
	default:
		stdout("%v\n", strings.Join(outputs, "\n"))
	}

	return
}

func convert(fn func(string) string, inputs ...string) (outputs []string) {
	for _, input := range inputs {
		outputs = append(outputs, fn(strings.TrimSpace(input)))
	}
	return
}

func stderr(format string, argv ...interface{}) {
	_, _ = fmt.Fprintf(os.Stderr, format, argv...)
}

func stdout(format string, argv ...interface{}) {
	_, _ = fmt.Fprintf(os.Stdout, format, argv...)
}
func fatal(format string, argv ...interface{}) {
	stderr(format, argv...)
	os.Exit(1)
}
