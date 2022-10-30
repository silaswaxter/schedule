build_dir := ./build
src_dir := ./src

readable_pdf := $(build_dir)/readable_schedule.pdf
printable_pdf := $(build_dir)/printable_schedule.pdf

booklet_source	:= $(src_dir)/booklet.adoc
booklet_theme := $(src_dir)/booklet-theme.yml

srcs := $(shell find $(src_dir) -name "*.adoc")

.phony: print $(readable_pdf) clean

print: $(printable_pdf)
	echo "This would be cool to do from cli in the future."

$(printable_pdf): $(readable_pdf)
	bash ./layout.sh $< $@

$(readable_pdf): $(booklet_source) $(booklet_theme) $(srcs)
	docker run -v $(shell pwd):/documents/ \
		--rm \
		asciidoctor/docker-asciidoctor \
		asciidoctor-pdf $(booklet_source) --theme $(booklet_theme) -o $@

clean:
	rm -rf $(build_dir)/*

