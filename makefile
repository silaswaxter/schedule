# This makefile is **not** correct. It always executes the build on all files
# regardless of modification.

BUILD_DIR := ./build
SRC_DIR := ./src
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIRECTORY := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

READABLE_DOC := readable_schedule.pdf
PRINTABLE_DOC := printable_schedule.pdf
TOP_LEVEL_SRC	:= $(SRC_DIR)/booklet.adoc
THEME_FILE := src/booklet-theme.yml
SRCS := $(shell find $(SRC_DIR) -name "*.adoc")

.phony: print $(BUILD_DIR)/$(READABLE_DOC) clean

print: $(BUILD_DIR)/$(PRINTABLE_DOC)
	echo "This would be cool to do from cli in the future."

$(BUILD_DIR)/$(PRINTABLE_DOC): $(BUILD_DIR)/$(READABLE_DOC)
	bash ./layout.sh $< $@

$(BUILD_DIR)/$(READABLE_DOC): $(TOP_LEVEL_SRC) $(THEME_FILE) $(SRCS)
	docker run -v $(shell pwd):/documents/ \
		--rm \
		asciidoctor/docker-asciidoctor \
		asciidoctor-pdf $(TOP_LEVEL_SRC) --theme $(THEME_FILE) -o $@

clean:
	rm -rf $(BUILD_DIR)/*

