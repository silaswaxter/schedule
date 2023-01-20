build_dir := build
src_dir := src

readable_pdf := $(build_dir)/readable_schedule.pdf
printable_pdf := $(build_dir)/printable_schedule.pdf

booklet_top_src	:= $(src_dir)/booklet.adoc
booklet_src := $(shell find $(src_dir)/ -name "*.adoc")
booklet_theme := $(src_dir)/booklet-theme.yml

days_src := $(shell find $(src_dir)/days -name *day.adoc)
days_readable_pdf := $(patsubst %.adoc,%.pdf,\
			 $(subst $(src_dir)/days,$(build_dir),\
			 $(patsubst %.adoc,%-readable.adoc,$(days_src))))
days_assemble_pdf := $(subst readable,assemble,$(days_readable_pdf))
days_theme := $(src_dir)/days/schedule-theme.yml

.phony: print $(readable_pdf) clean

print: $(printable_pdf)
	$(info CLI printing coming soon.)

$(printable_pdf): $(readable_pdf)
	bash ./layout.sh $< $@

$(readable_pdf): $(booklet_top_src) $(booklet_theme) $(days_assemble_pdf) $(booklet_src)
	docker run -v $(shell pwd):/documents/ \
		--rm \
		asciidoctor/docker-asciidoctor \
		asciidoctor-pdf $< \
		-a day-pdf-prefix="$(build_dir)/" \
		-a day-pdf-suffix="-assemble.pdf" \
		--theme $(booklet_theme) -o $@

%-assemble.pdf: %-readable.pdf
	bash ./schedule_layout.sh $< $@

$(build_dir)/%-readable.pdf: $(src_dir)/days/schedule.adoc $(src_dir)/days/%.adoc $(days_theme)
	docker run -v $(shell pwd):/documents/ \
		--rm \
		asciidoctor/docker-asciidoctor \
		asciidoctor-pdf $< \
		-a schedule-day=$* \
		--theme $(days_theme) -o $@

clean:
	rm -rf $(build_dir)/*

