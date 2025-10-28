#!/usr/bin/env bash

# Inspired by https://github.com/bahamas10/ysap/blob/main/code/2025-08-21-progress-bar/progress-bar

progress_bar() {
	local current=$1
	local len=$2
	local message="${3:-}"

	local bar_char='|'
	local empty_char=' '
	local length=50
	local perc_done=$((current * 100 / len))
	local num_bars=$((perc_done * length / 100))

	local i
	local s='['
	for ((i = 0; i < num_bars; i++)); do
		s+=$bar_char
	done
	for ((i = num_bars; i < length; i++)); do
		s+=$empty_char
	done
	s+=']'

	echo -ne "$s $current/$len ($perc_done%) \t$message\r"
}
