#!/bin/bash
# Script takes an input pdf 

temp_file="/tmp/pdf_print_layout.ps"

# Describe printing configuration. Tested only for 2 page placement with
# following input and print sizes.
declare -ri number_pages_placed=2
# dimensions in inches
declare -r \
  reader_w="3.5" \
  reader_h="5.6" \
  print_w="8.5" \
  print_h="11" \
  print_margin="0.4"

pdf2ps ${1} ${temp_file}

# reorder pages for booklet
psbook --quiet ${temp_file} |
# place the pages.
# note: psnup will scale the page depending on the input and output page size.
#       Since 2 pages are placed side-by-side, the width of the output page must
#       be at least 2 * input_page_width. The interactions with the specified
#       output page size height are more complicated. If large enough, the
#       placed pages will be scaled up to fit the size. At ~medium~ specified
#       size (with respect to input page height), the output page is respected.
#       When the output page height is smaller than the input page height, the
#       specified output page height is ignored and set by psnup.
#
# `border` equation was experimentally derived. Uses `bc` with 4 significant
# figures.
  psnup --border="-$(scale=4; bc -l <<<"0.2 * ${print_margin}")in" \
  --draw --quiet \
  --margin="${print_margin}in" \
  --inpaper="${reader_w}inx${reader_h}in" \
  --paper="$(bc<<<"${number_pages_placed}*${reader_w}")inx${reader_h}in" \
  -${number_pages_placed} |
  # shift the odd pages for long-edge two-side printing
  pstops --quiet \
  --inpaper="${reader_w}inx${reader_h}in" \
  --paper="${print_w}inx${print_h}in" \
  --specs=2:0\(0in,0in\),1\($(bc<<<"${print_w}-2*(${reader_w})")in,0in\) |
  # use stdin for conversion
  ps2pdf - ${2}
