#?
#? Makrocosm example project
#? =========================
#?

export RELEASE_VERSION = $(shell git describe --dirty --tag --always)

# Use a custom workspace that extends Makrocosm's Ubuntu 24.04 workspace
WORKSPACE = workspace

.PHONY: all
all: #? Build firmware and disk images for all platforms

.PHONY: release
release: #? Copy all platforms' versioned firmware and disk images to the "release" directory
		$(AT)echo "---\nRelease version: $(RELEASE_VERSION)"

# Rebuild custom workspace image on changes to the base image
build/workspace: build/makrocosm/workspace/ubuntu-24.04

#?

include alpine/common/build.mk
include alpine/x64/build.mk
include alpine/orangepi-one/build.mk
include alpine/rpi/build.mk
include makrocosm/rules.mk
