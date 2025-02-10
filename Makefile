#?
#? Makrocosm example project
#? =========================
#?

export RELEASE_VERSION = $(shell git describe --dirty --tag --always)

.PHONY: all
all: #? Build firmware and disk images for all platforms

.PHONY: release
release: #? Copy all platforms' versioned firmware and disk images to the "release" directory
		$(AT)echo "---\nRelease version: $(RELEASE_VERSION)"

#?

include alpine/common/build.mk
include alpine/x64/build.mk
include alpine/orangepi-one/build.mk
include makrocosm/rules.mk
