#!/bin/bash

iverilog test.v ../../hdl/video/jtframe_vtimer.v -o sim -DSIMULATION && sim -lxt