#!/bin/bash

ITERS=0
while [ $ITERS -lt 5 ]; do
	let ITERS=ITERS+1;
	"$@"; 
done  
