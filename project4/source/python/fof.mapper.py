#!/usr/bin/python
import sys

for line in sys.stdin:
	person = line.strip().split()
	key = person[0]
	n = len(person)
	if (n > 2):
		for i in range(1, n-1):
			for j in range(i+1, n):
				triad = [key, person[i], person[j]]
				if (triad[1] < triad[2]):
					print triad[0], triad[1], triad[2], 1
				else:
					print triad[0], triad[2], triad[1], 1

				if (triad[0] < triad[2]):
					print triad[1], triad[0], triad[2], 1
				else:
					print triad[1], triad[2], triad[0], 1

				if (triad[0] < triad[1]):
					print triad[2], triad[0], triad[1], 1
				else:
					print triad[2], triad[1], triad[0], 1


				
					
	

