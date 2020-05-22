#!/bin/sh
shift  # get rid of the '-c' supplied by make.
time bash -c "$*"
