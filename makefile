build_dir := ./build
src_dir := ./src

readable_pdf := $(build_dir)/readable_schedule.pdf
printable_pdf := $(build_dir)/printable_schedule.pdf

booklet_source	:= $(src_dir)/booklet.adoc
booklet_theme := $(src_dir)/booklet-theme.yml

srcs := $(shell find $(src_dir) -name "*.adoc")

monday_pdf := $(build_dir)/monday.pdf
pages_monday_pdf := $(build_dir)/pages_monday.pdf
days_schedule_theme := $(src_dir)/days/schedule-theme.yml

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

$(monday_pdf): $(pages_monday_pdf)
	bash ./schedule_layout.sh $< $@

$(pages_monday_pdf): $(src_dir)/days/schedule.adoc $(src_dir)/days/monday.adoc $(days_schedule_theme)
	docker run -v $(shell pwd):/documents/ \
		--rm \
		asciidoctor/docker-asciidoctor \
		asciidoctor-pdf $< -a schedule-day="monday" \
		--theme $(days_schedule_theme) -o $@

clean:
	rm -rf $(build_dir)/*

