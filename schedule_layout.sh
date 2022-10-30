#!/bin/bash
# Take an input pdf, argument #1, and place the pages side-by-side then write
# the new pdf to argument #2.

temp_file="/tmp/pdf_schedule_layout.ps"

# Describe printing configuration. Tested only for 2 page placement with
# following input and print sizes.
declare -ri number_pages_placed=2
# dimensions in inches
declare -r \
  input_w="1.75" \
  input_h="5.6" \
  output_w="3.5" \
  output_h="5.6" \
  output_margin="0.0"

pdf2ps ${1} ${temp_file}

# place files side-by-side then convert
pstops --quiet \
  --inpaper="${input_w}inx${input_h}in" \
  --paper="5inx8in" \
  --specs=2:0\(0in,0in\)+1\(${input_w}in,0in\)  \
  ${temp_file} |
  ps2pdf -g$(bc<<<"720*${output_w}/1")x$(bc<<<"720*${output_h}/1") - ${2}

