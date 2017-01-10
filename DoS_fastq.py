#!/usr/bin/env python2

__author__ = "Ludovic Duvaux"
__maintainer__ = "Ludovic Duvaux"
__license__ = "GPL_v3"

import sys

usage="""
SYNOPSIS:
zcat file_R1.fastq.gz file_R2.fastq.gz | DoS_fastq.py sample Gsize

WARNING: if you use the script without the pipe, it will go on till infinity!
Currently, I don't know how to check if STDIN is empty.

DESCRIPTION:
Compute depth of sequencing (coverage) from standard input (from fastq files).

ARGUMENTS:
	Gsize		   genome size in bp to compute DoS (can be '10000' or '1e4')
	sample		name of the processed sample (for output)
"""

argv = sys.argv
GSIZE = argv[-1]
SAM = argv[-2]

i = 1	# ith line
nreads= 0
som = 0
for l in sys.stdin:
	if i % 4 == 2:   # look only sequences lines
		#~print l.strip()
		som += len(l.strip())
		nreads += 1
	# increment at the end
	i += 1
sys.stdin.close()

# print results
cov = som / float(GSIZE)
res = [ SAM, nreads, som / 1e6, som / float(nreads), cov ]
res = [ str(x) for x in res ]
print "\t".join(res)
