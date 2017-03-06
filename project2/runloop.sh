#!/bin/bash

ITERS=0
while [ $ITERS -lt 20 ]; do
	let ITERS=ITERS+1;
	./filter_parallel;
done  
