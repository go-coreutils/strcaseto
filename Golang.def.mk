#!/usr/bin/make --no-print-directory --jobs=1 --environment-overrides -f

# Copyright (c) 2023  The Go-Curses Authors
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

GOLANG_MAKEFILE_KEYS += DEF
GOLANG_DEF_MK_VERSION := v0.1.3

.PHONY: all help
.PHONY: clean distclean realclean
.PHONY: local unlocal deps tidy fmt be-update generate
.PHONY: debug build build-all build-amd64 build-arm64
.PHONY: release release-all release-amd64 release-arm64
.PHONY: install install-autocomplete
.PHONY: test coverage reportcard

SRC_CMD_PATH ?= .
SRC_AUTOCOMPLETE_FILE ?= ./bash_autocomplete
CUSTOM_HELP_KEYS ?=

all: help

help:
	@echo "usage: make [target]"
	@echo
	@echo "golang qa targets:"
	@echo "  test           - perform all available tests"
	@echo "  coverage       - generate coverage reports"
	@echo "  reportcard     - run sanity checks"

	@echo
	@echo "cleanup targets:"
	@echo "  clean       - cleans package and built files"
	@echo "  distclean   - clean and removes extraneous files"

	@echo
	@echo "build targets:"
	@echo "  debug       - build debug ${BUILD_NAME}"
	@echo "  build       - build clean ${BUILD_NAME}"
	@echo "  release     - build clean and compress ${BUILD_NAME}"

	@echo
	@echo "cross-build targets:"
	@echo "  build-all     - both build-arm64 and build-amd64"
	@echo "  build-arm64   - build clean ${BIN_NAME}.${BUILD_OS}.arm64"
	@echo "  build-amd64   - build clean ${BIN_NAME}.${BUILD_OS}.amd64"
	@echo "  release-all   - both release-arm64 and release-amd64"
	@echo "  release-arm64 - build clean and compress ${BIN_NAME}.${BUILD_OS}.arm64"
	@echo "  release-amd64 - build clean and compress ${BIN_NAME}.${BUILD_OS}.amd64"

	@echo
	@echo "install targets:"
	@echo "  install       - installs ${BUILD_NAME} to ${DESTDIR}${prefix}/bin/${BIN_NAME}"
	@echo "  install-arm64 - installs ${BIN_NAME}.${BUILD_OS}.arm64 to ${DESTDIR}${prefix}/bin/${BIN_NAME}"
	@echo "  install-amd64 - installs ${BIN_NAME}.${BUILD_OS}.amd64 to ${DESTDIR}${prefix}/bin/${BIN_NAME}"

ifdef help_custom_targets
	@echo
	@echo "custom targets:"
	$(call help_custom_targets)
endif

	@$(if ${CUSTOM_HELP_SECTIONS},$(foreach section,${CUSTOM_HELP_SECTIONS},\
echo;\
echo "$($(section)_NAME) targets:" \
$(foreach key,$($(section)_KEYS),; echo "  $($(section)_$(key)_TARGET)	- $($(section)_$(key)_USAGE)")\
))

	@echo
	@echo "go helpers:"
	@echo "  deps        - install dependencies"
	@echo "  fmt         - run gofmt and goimports"
	@echo "  tidy        - run go mod tidy"
	@echo "  local       - add go.mod local GOPKG_KEYS replacements"
	@echo "  unlocal     - remove go.mod local GOPKG_KEYS replacements"
	@echo "  generate    - run go generate ./..."
	@echo "  be-update   - get latest GOPKG_KEYS dependencies"

	@echo
	@echo "Notes:"
	@echo "  GOPKG_KEYS are go packages managed by this Makefile and the following"
	@echo "  are the included packages:" \
		$(if ${GOPKG_KEYS},$(foreach key,${GOPKG_KEYS},; echo "    $(key): $($(key)_GO_PACKAGE) ($($(key)_LOCAL_PATH))"))

	@echo $(foreach key,${GOLANG_MAKEFILE_KEYS},$(shell \
	echo ";echo \"Golang.$(shell perl -e 'print lc("$(key)");').mk: $(GOLANG_$(key)_MK_VERSION)\"" \
))

clean:
	@$(call __clean,${CLEAN_FILES})

distclean: clean
	@$(call __clean,${DISTCLEAN_FILES})

realclean: distclean
	@$(call __clean,${REALCLEAN_FILES})

debug: BUILD_VERSION=$(call __tag_ver)
debug: BUILD_RELEASE=$(call __rel_ver)
debug: TRIM_PATHS=$(call __go_trim_path)
debug: __golang
	@$(call __go_build_debug,"${BUILD_NAME}",${BUILD_OS},${BUILD_ARCH},${SRC_CMD_PATH})
	@${SHASUM_CMD} "${BUILD_NAME}"

build: BUILD_VERSION=$(call __tag_ver)
build: BUILD_RELEASE=$(call __rel_ver)
build: TRIM_PATHS=$(call __go_trim_path)
build: __golang
	@$(call __go_build_release,"${BUILD_NAME}",${BUILD_OS},${BUILD_ARCH},${SRC_CMD_PATH})
	@${SHASUM_CMD} "${BUILD_NAME}"

build-amd64: BUILD_VERSION=$(call __tag_ver)
build-amd64: BUILD_RELEASE=$(call __rel_ver)
build-amd64: TRIM_PATHS=$(call __go_trim_path)
build-amd64: __golang
	@$(call __go_build_release,"${BIN_NAME}.${BUILD_OS}.amd64",${BUILD_OS},amd64,${SRC_CMD_PATH})
	@${SHASUM_CMD} "${BIN_NAME}.${BUILD_OS}.amd64"

build-arm64: BUILD_VERSION=$(call __tag_ver)
build-arm64: BUILD_RELEASE=$(call __rel_ver)
build-arm64: TRIM_PATHS=$(call __go_trim_path)
build-arm64: __golang
	@$(call __go_build_release,"${BIN_NAME}.${BUILD_OS}.arm64",${BUILD_OS},arm64,${SRC_CMD_PATH})
	@${SHASUM_CMD} "${BIN_NAME}.${BUILD_OS}.arm64"

build-all: build-amd64 build-arm64

release: build
	@$(call __upx_build,"${BUILD_NAME}")

release-arm64: build-arm64
	@$(call __upx_build,"${BIN_NAME}.${BUILD_OS}.arm64")

release-amd64: build-amd64
	@$(call __upx_build,"${BIN_NAME}.${BUILD_OS}.amd64")

release-all: release-amd64 release-arm64

install:
	@if [ -f "${BUILD_NAME}" ]; then \
		echo "# ${BUILD_NAME} present"; \
		$(call __install_exe,"${BUILD_NAME}","${INSTALL_BIN_PATH}/${BIN_NAME}"); \
	else \
		echo "error: missing ${BUILD_NAME} binary" 1>&2; \
		false; \
	fi

install-arm64:
	@if [ -f "${BIN_NAME}.${BUILD_OS}.arm64" ]; then \
		echo "# ${BIN_NAME}.${BUILD_OS}.arm64 present"; \
		$(call __install_exe,"${BIN_NAME}.${BUILD_OS}.arm64","${INSTALL_BIN_PATH}/${BIN_NAME}"); \
	else \
		echo "error: missing ${BIN_NAME}.${BUILD_OS}.arm64 binary" 1>&2; \
		false; \
	fi

install-amd64:
	@if [ -f "${BIN_NAME}.${BUILD_OS}.amd64" ]; then \
		echo "# ${BIN_NAME}.${BUILD_OS}.amd64 present"; \
		$(call __install_exe,"${BIN_NAME}.${BUILD_OS}.amd64","${INSTALL_BIN_PATH}/${BIN_NAME}"); \
	else \
		echo "error: missing ${BIN_NAME}.${BUILD_OS}.amd64 binary" 1>&2; \
		false; \
	fi

install-autocomplete: AUTOCOMPLETE_FILE=${INSTALL_AUTOCOMPLETE_PATH}/${BIN_NAME}
install-autocomplete:
	@if [ ! -f "${SRC_AUTOCOMPLETE_FILE}" ]; then \
		echo "error: SRC_AUTOCOMPLETE_FILE=${SRC_AUTOCOMPLETE_FILE} not found"; \
		false; \
	fi
	@echo "# installing ${BIN_NAME} bash_autocomplete to: ${AUTOCOMPLETE_FILE}"
	@$(call __install_exe,${SRC_AUTOCOMPLETE_FILE},${AUTOCOMPLETE_FILE})

deps: __deps

tidy: __tidy

be-update: __be_update

local: __local

unlocal: __unlocal

fmt: __fmt

reportcard: __reportcard

test: __test

coverage: __coverage

goconvey: __goconvey

generate: __generate
