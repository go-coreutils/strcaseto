# strcaseto

Utility for converting strings to specific cases such as CamelCase, kebab-case or snake_case.

## INSTALLATION

``` shell
> go install github.com/go-coreutils/strcase/cmd/strcaseto@latest
```

## DOCUMENTATION

``` shell
> strcaseto --help
NAME:
   strcaseto - convert strings to various cases

USAGE:
   strcaseto [option] <string> [string...]
   echo "one-or-more-lines" | strcaseto [option]

VERSION:
   v0.1.0 (trunk)

DESCRIPTION:
   Convert command line arguments (or lines of os.Stdin) to a specific case.
   Outputting one line of text per input given.

GLOBAL OPTIONS:
   Cases
   --camel            (default: false)
   --kebab            (default: false)
   --lower-camel      (default: false)
   --screaming-kebab  (default: false)
   --screaming-snake  (default: false)
   --snake            (default: false)

   General
   --help, -h, --usage  (default: false)
   --version, -V        (default: false)
```

## symlink shortcuts

The strcaseto utility has some hidden shortcuts. Given the default
`$GOPATH/bin/strcaseto` path, the following symlinks remove the
need for any command line arguments to convert to specific cases:

``` shell
> for name in camel kebab lower-camel screaming-kebab screaming-snake snake; \
do \
    ln -sv "${GOPATH}/bin/strcaseto" "${GOPATH}/bin/${name}"; \
done
'$GOPATH/bin/camel' -> '$GOPATH/bin/strcaseto'
'$GOPATH/bin/kebab' -> '$GOPATH/bin/strcaseto'
'$GOPATH/bin/lower-camel' -> '$GOPATH/bin/strcaseto'
'$GOPATH/bin/screaming-kebab' -> '$GOPATH/bin/strcaseto'
'$GOPATH/bin/screaming-snake' -> '$GOPATH/bin/strcaseto'
'$GOPATH/bin/snake' -> '$GOPATH/bin/strcaseto'
```

Now you can use the individual cases without needing to include command-line flags.

``` shell
> camel "this string"
ThisString
> (echo "this string"; "that string") | screaming-kebab
THIS-STRING
THAT-STRING
```

## LICENSE

```
Copyright 2023  The Go-Curses Authors

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
