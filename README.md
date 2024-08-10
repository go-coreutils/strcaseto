[![Go](https://img.shields.io/badge/Go-v1.22.6-blue.svg)](https://go.dev)
[![GoDoc](https://img.shields.io/badge/godoc-reference-blue.svg)](https://pkg.go.dev/github.com/go-coreutils/strcaseto)
[![GoReportCard](https://goreportcard.com/badge/github.com/go-coreutils/strcaseto)](https://goreportcard.com/report/github.com/go-coreutils/strcaseto)

# strcaseto

Utility for converting strings to specific cases such as `CamelCase`,
`kebab-case` and `snake_case`.

The following is a table of all the strcase types supported:

| strcase            | example              |
| ------------------ | -------------------- |
| `camel`            | CamelCase            |
| `lower-camel`      | lowerCamelCase       |
| `kebab`            | kebab-case           |
| `screaming-kebab`  | SCREAMING-KEBAB-CASE |
| `snake`            | snake_case           |
| `screaming-snake`  | SCREAMING_SNAKE_CASE |

## INSTALLATION

``` shell
# note: requires Go v1.22.6
> go install github.com/go-coreutils/strcase/cmd/strcaseto@latest
```

### SYMLINKS

`strcaseto` supports a symlink feature for simplifying the usage of any
supported strcase type.

For example: `strcaseto --kebab CamelCasedInput` would print `camel-cased-input`
when run. Using a symlink to `kebab` would reduce the number of characters typed
on the command line to: `kebab CamcelCasedInput`.

The following naming conventions are supported:

- `to-<strcase>-case`
- `to-<strcase>`
- `<strcase>`

Here's a little shell scripting to make these symlinks in `${GOPATH}/bin` using
the shortest naming convention supported:

``` shell
for DST in camel kebab lower-camel screaming-kebab screaming-snake snake; \
do \
  ln -sv "${GOPATH}/bin/strcaseto" "${GOPATH}/bin/${DST}"; \
done
```

Now you can use the individual cases without needing to include command-line
flags.

```
> camel "this string"
ThisString
> (echo -e "this string\nthat string") | screaming-kebab
THIS-STRING
THAT-STRING
```

## DOCUMENTATION

``` shell
> strcaseto --help
NAME:
   strcaseto - convert strings to various cases

USAGE:
   strcaseto.linux.arm64 [option] <string> [string...]
   echo "one-or-more-lines" | strcaseto.linux.arm64 [option]

VERSION:
   v0.2.0 (trunk)

DESCRIPTION:
   Convert command line arguments (or lines of os.Stdin) to a specific case.
   Outputting one line of text per input given.

GLOBAL OPTIONS:
   Cases

   --camel, -c
   --kebab, -k
   --lower-camel, -C
   --screaming-kebab, -K
   --screaming-snake, -S
   --snake, -s

   General

   --help, -h, --usage
   --version, -V
```

## LICENSE

```
Copyright 2024  The Go-CoreUtils Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use file except in compliance with the License.
You may obtain a copy of the license at

 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
