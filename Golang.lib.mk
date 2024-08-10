#!/usr/bin/make --no-print-directory --jobs=1 --environment-overrides -f

# Copyright (c) 2023  The Go-Enjin Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

GOLANG_MAKEFILE_KEYS += LIB
GOLANG_LIB_MK_VERSION := v0.1.3

#
#: Go-Curses Packages
#

CDK_GO_PACKAGE ?= github.com/go-curses/cdk
CDK_LOCAL_PATH ?= ../cdk

CTK_GO_PACKAGE ?= github.com/go-curses/ctk
CTK_LOCAL_PATH ?= ../ctk

#
#: Core Library Packages
#

AUTO_CORELIBS ?= false

CORELIBS_BASE ?= github.com/go-corelibs
CORELIBS_PATH ?= ../../go-corelibs

FOUND_CORELIBS := `\
find * \
	-name "*.go" -exec grep '"github.com/go-corelibs/' \{\} \; \
	| perl -pe 's!^[^"]*!!;s![\s"]!!g;s!github\.com/go-corelibs/!!;s!$$!\n!;' \
	| sort -u \
`

corelibs:
	@if [ -n "${FOUND_CORELIBS}" ]; then \
		for CL in ${FOUND_CORELIBS}; do \
			echo "# github.com/go-corelibs/$${CL}"; \
		done; \
	else \
		echo "# no go-corelibs detected"; \
	fi

ifeq (${AUTO_CORELIBS},true)
#: grep *.go files for go-corelibs imports

ifeq (chdirs,$(shell echo "${FOUND_CORELIBS}" | grep '^chdirs$$'))
GOPKG_KEYS += CL_CHDIRS
endif

ifeq (convert,$(shell echo "${FOUND_CORELIBS}" | grep '^convert$$'))
GOPKG_KEYS += CL_CONVERT
endif

ifeq (diff,$(shell echo "${FOUND_CORELIBS}" | grep '^diff$$'))
GOPKG_KEYS += CL_DIFF
endif

ifeq (filewriter,$(shell echo "${FOUND_CORELIBS}" | grep '^filewriter$$'))
GOPKG_KEYS += CL_FILEWRITER
endif

ifeq (fmtstr,$(shell echo "${FOUND_CORELIBS}" | grep '^fmtstr$$'))
GOPKG_KEYS += CL_FMTSTR
endif

ifeq (globs,$(shell echo "${FOUND_CORELIBS}" | grep '^globs$$'))
GOPKG_KEYS += CL_GLOBS
endif

ifeq (maps,$(shell echo "${FOUND_CORELIBS}" | grep '^maps$$'))
GOPKG_KEYS += CL_MAPS
endif

ifeq (maths,$(shell echo "${FOUND_CORELIBS}" | grep '^maths$$'))
GOPKG_KEYS += CL_MATHS
endif

ifeq (mock-stdio,$(shell echo "${FOUND_CORELIBS}" | grep '^mock-stdio$$'))
GOPKG_KEYS += CL_MOCK_STDIO
endif

ifeq (notify,$(shell echo "${FOUND_CORELIBS}" | grep '^notify$$'))
GOPKG_KEYS += CL_NOTIFY
endif

ifeq (path,$(shell echo "${FOUND_CORELIBS}" | grep '^path$$'))
GOPKG_KEYS += CL_PATH
endif

ifeq (replace,$(shell echo "${FOUND_CORELIBS}" | grep '^replace$$'))
GOPKG_KEYS += CL_REPLACE
endif

ifeq (regexps,$(shell echo "${FOUND_CORELIBS}" | grep '^regexps$$'))
GOPKG_KEYS += CL_REGEXPS
endif

ifeq (run,$(shell echo "${FOUND_CORELIBS}" | grep '^run$$'))
GOPKG_KEYS += CL_RUN
endif

ifeq (slices,$(shell echo "${FOUND_CORELIBS}" | grep '^slices$$'))
GOPKG_KEYS += CL_SLICES
endif

ifeq (spinner,$(shell echo "${FOUND_CORELIBS}" | grep '^spinner$$'))
GOPKG_KEYS += CL_SPINNER
endif

ifeq (strings,$(shell echo "${FOUND_CORELIBS}" | grep '^strings$$'))
GOPKG_KEYS += CL_STRINGS
endif

ifeq (strcases,$(shell echo "${FOUND_CORELIBS}" | grep '^strcases$$'))
GOPKG_KEYS += CL_STRCASES
endif

ifeq (words,$(shell echo "${FOUND_CORELIBS}" | grep '^words$$'))
GOPKG_KEYS += CL_WORDS
endif

#: end AUTO_CORELIBS
endif

CL_CHDIRS_GO_PACKAGE ?= ${CORELIBS_BASE}/chdirs
CL_CHDIRS_LOCAL_PATH ?= ${CORELIBS_PATH}/chdirs

CL_CONVERT_GO_PACKAGE ?= ${CORELIBS_BASE}/convert
CL_CONVERT_LOCAL_PATH ?= ${CORELIBS_PATH}/convert

CL_DIFF_GO_PACKAGE ?= ${CORELIBS_BASE}/diff
CL_DIFF_LOCAL_PATH ?= ${CORELIBS_PATH}/diff

CL_FILEWRITER_GO_PACKAGE ?= ${CORELIBS_BASE}/filewriter
CL_FILEWRITER_LOCAL_PATH ?= ${CORELIBS_PATH}/filewriter

CL_FMTSTR_GO_PACKAGE ?= ${CORELIBS_BASE}/fmtstr
CL_FMTSTR_LOCAL_PATH ?= ${CORELIBS_PATH}/fmtstr

CL_GLOBS_GO_PACKAGE ?= ${CORELIBS_BASE}/globs
CL_GLOBS_LOCAL_PATH ?= ${CORELIBS_PATH}/globs

CL_MAPS_GO_PACKAGE ?= ${CORELIBS_BASE}/maps
CL_MAPS_LOCAL_PATH ?= ${CORELIBS_PATH}/maps

CL_MATHS_LOCAL_PATH ?= ${CORELIBS_PATH}/maths
CL_MATHS_GO_PACKAGE ?= ${CORELIBS_BASE}/maths

CL_MOCK_STDIO_LOCAL_PATH ?= ${CORELIBS_PATH}/mock-stdio
CL_MOCK_STDIO_GO_PACKAGE ?= ${CORELIBS_BASE}/mock-stdio

CL_NOTIFY_GO_PACKAGE ?= ${CORELIBS_BASE}/notify
CL_NOTIFY_LOCAL_PATH ?= ${CORELIBS_PATH}/notify

CL_PATH_GO_PACKAGE ?= ${CORELIBS_BASE}/path
CL_PATH_LOCAL_PATH ?= ${CORELIBS_PATH}/path

CL_REGEXPS_GO_PACKAGE ?= ${CORELIBS_BASE}/regexps
CL_REGEXPS_LOCAL_PATH ?= ${CORELIBS_PATH}/regexps

CL_REPLACE_GO_PACKAGE ?= ${CORELIBS_BASE}/replace
CL_REPLACE_LOCAL_PATH ?= ${CORELIBS_PATH}/replace

CL_RUN_GO_PACKAGE ?= ${CORELIBS_BASE}/run
CL_RUN_LOCAL_PATH ?= ${CORELIBS_PATH}/run

CL_SCANNERS_GO_PACKAGE ?= ${CORELIBS_BASE}/scanners
CL_SCANNERS_LOCAL_PATH ?= ${CORELIBS_PATH}/scanners

CL_SLICES_GO_PACKAGE ?= ${CORELIBS_BASE}/slices
CL_SLICES_LOCAL_PATH ?= ${CORELIBS_PATH}/slices

CL_SPINNER_GO_PACKAGE ?= ${CORELIBS_BASE}/spinner
CL_SPINNER_LOCAL_PATH ?= ${CORELIBS_PATH}/spinner

CL_STRCASES_GO_PACKAGE ?= ${CORELIBS_BASE}/strcases
CL_STRCASES_LOCAL_PATH ?= ${CORELIBS_PATH}/strcases

CL_STRINGS_GO_PACKAGE ?= ${CORELIBS_BASE}/strings
CL_STRINGS_LOCAL_PATH ?= ${CORELIBS_PATH}/strings

CL_WORDS_GO_PACKAGE ?= ${CORELIBS_BASE}/words
CL_WORDS_LOCAL_PATH ?= ${CORELIBS_PATH}/words
