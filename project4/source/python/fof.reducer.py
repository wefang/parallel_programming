#!/usr/bin/python 

import sys
from collections import Counter

lines = sys.stdin.readlines()
tri = [k for k, v in Counter(lines).iteritems() if v >= 3]
for x in sorted(tri):
	(a, b, c, d) = x.strip().split()
	print a, b, c
