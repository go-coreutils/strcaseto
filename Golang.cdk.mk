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

GOLANG_MAKEFILE_KEYS += CDK

GOLANG_CDK_MK_VERSION := v0.1.2

CUSTOM_HELP_SECTIONS += CDK_HELP

CDK_HELP_NAME := "go-curses"
CDK_HELP_KEYS := DRUN PCPU PMEM

CDK_HELP_DRUN_TARGET := debug-run
CDK_HELP_DRUN_USAGE  := run the debug build (and sanely handle crashes)

CDK_HELP_PCPU_TARGET := profile.cpu
CDK_HELP_PCPU_USAGE  := run the dev build and profile CPU

CDK_HELP_PMEM_TARGET := profile.mem
CDK_HELP_PMEM_USAGE  := run the dev build and profile MEM

define __debug_run
	if [ -f "$(1)" ]; then \
		if [ "${DLV_DEBUG}" == "true" ]; then \
			echo "# delving: $(1) $(2)"; \
			( dlv.sh ./$(1) $(2) ) 2>> $(3); \
		else \
			echo "# running: $(1) $(2)"; \
			( ./$(1) $(2) ) 2>> $(3); \
		fi; \
		if [ $$? -eq 0 ]; then \
			echo "# $(1) exited normally."; \
		else \
			stty sane; echo ""; \
			echo "# $(1) crashed, see: $(3)"; \
			read -p "# Press <Enter> to reset terminal, <Ctrl+C> to cancel" RESP; \
			reset; \
			echo "# $(1) crashed, terminal reset, see: $(3)"; \
		fi; \
	else \
		echo "# $(1) not found"; \
	fi
endef

define __pprof_run
	if [ -f "$(1)" ]; then \
		echo "# profiling: $(1) $(2)"; \
		( $(5) ./$(1) $(2) ) 2>> $(3); \
		if [ $$? -eq 0 ]; then \
			echo "# $(1) exited normally."; \
			if [ -f "$(4)" ]; \
			then \
				read -p "# Press enter to open a pprof instance" JUNK \
				&& ( go tool pprof -http=:8080 "$(4)" 2> /dev/null ); \
			else \
				echo "# pprof file not found: $(4)"; \
			fi ; \
		else \
			stty sane; echo ""; \
			echo "# $(1) crashed, see: $(3)"; \
			read -p "# Press <Enter> to reset terminal, <Ctrl+C> to cancel" RESP; \
			reset; \
			echo "# $(1) crashed, terminal reset, see: $(3)"; \
		fi; \
	else \
		echo "# $(1) not found"; \
	fi
endef

debug-run: export GO_CDK_LOG_FILE=./${BUILD_NAME}.cdk.log
debug-run: export GO_CDK_LOG_LEVEL=${LOG_LEVEL}
debug-run: export GO_CDK_LOG_FULL_PATHS=true
debug-run: debug
	@$(call __debug_run,${BUILD_NAME},${RUN_ARGS},${GO_CDK_LOG_FILE})

debug-dlv: export DLV_DEBUG=true
debug-dlv: debug-run

profile.cpu: export GO_CDK_LOG_FILE=./${BUILD_NAME}.cdk.log
profile.cpu: export GO_CDK_LOG_LEVEL=${LOG_LEVEL}
profile.cpu: export GO_CDK_LOG_FULL_PATHS=true
profile.cpu: export GO_CDK_PROFILE_PATH=/tmp/${BUILD_NAME}.cdk.pprof
profile.cpu: export GO_CDK_PROFILE=cpu
profile.cpu: debug
	@rm -rf   "${GO_CDK_PROFILE_PATH}" 2>/dev/null || true
	@mkdir -p "${GO_CDK_PROFILE_PATH}" 2>/dev/null || true
	@$(call __pprof_run,${BUILD_NAME},${RUN_ARGS},${GO_CDK_LOG_FILE},${GO_CDK_PROFILE_PATH}/cpu.pprof,GO_CDK_LOG_FILE=${GO_CDK_LOG_FILE} GO_CDK_LOG_LEVEL=${GO_CDK_LOG_LEVEL} GO_CDK_LOG_FULL_PATHS=${GO_CDK_LOG_FULL_PATHS} GO_CDK_PROFILE_PATH=${GO_CDK_PROFILE_PATH} GO_CDK_PROFILE=${GO_CDK_PROFILE})

profile.mem: export GO_CDK_LOG_FILE=./${BUILD_NAME}.log
profile.mem: export GO_CDK_LOG_LEVEL=${LOG_LEVEL}
profile.mem: export GO_CDK_LOG_FULL_PATHS=true
profile.mem: export GO_CDK_PROFILE_PATH=/tmp/${BUILD_NAME}.cdk.pprof
profile.mem: export GO_CDK_PROFILE=mem
profile.mem: debug
	@rm -rf   "${GO_CDK_PROFILE_PATH}" 2>/dev/null || true
	@mkdir -p "${GO_CDK_PROFILE_PATH}" 2>/dev/null || true
	@$(call __pprof_run,${BUILD_NAME},${RUN_ARGS},${GO_CDK_LOG_FILE},${GO_CDK_PROFILE_PATH}/mem.pprof,GO_CDK_LOG_FILE=${GO_CDK_LOG_FILE} GO_CDK_LOG_LEVEL=${GO_CDK_LOG_LEVEL} GO_CDK_LOG_FULL_PATHS=${GO_CDK_LOG_FULL_PATHS} GO_CDK_PROFILE_PATH=${GO_CDK_PROFILE_PATH} GO_CDK_PROFILE=${GO_CDK_PROFILE})
