#!/usr/bin/env julia

# dependencies
# - julia version 0.4.5

__author__ = "Ludovic Duvaux"
__maintainer__ = "Ludovic Duvaux"
__license__ = "GPL_v3"


usage="
SYNOPSIS:
zcat file1.fastq.gz file2.fastq.gz | DoS_fastq.jl [-c] [-D] [-n sample_name] Gsize

WARNING: if you use teh script without any STDIN (with no data from a pipe), it will go on till infinity!
Currently, I don't know how to check if STDIN is empty.

DESCRIPTION:
Compute depth of sequencing (coverage) from standard input (from fastq files).

ARGUMENTS:
    Gsize           genome size in bp to compute DoS (can be '10000' or '1e4')

OPTIONS:
    -D              debug mode
    -n              sample name to be displayed in final table ['Allreads']
    -c              write column header to standard output (useful for 
                    loops in bash wrapper)
    -h              print help and exit (irrespectively to other arguments)

EXAMPLE:
zcat sample1_pe*.fastq.gz | DoS_fastq.jl 
"

# functions
function get_arg(args, i, fun = x->x)
	if length(args) < i+1
		error("expected argument after $(args[i])")
	end
	i += 1
	fun(args[i]), i
end

# print help and exit
#~println(ARGS)
if "-h" in ARGS
    print(usage)
    exit()
end

# get other arguments
i = 1 ; gooda = r"-[Dnc]"
GSIZE = "" ; nom = "Allreads"; w_header = "false" ; debug = "false"
while i ≤ length(ARGS)
    a = ARGS[i]
    
    if i != length(ARGS) && !ismatch(gooda, a)
        println("ERROR: Bad argument '$a' in the command line")
        println("       !!! Beware that concatenation of options is not allowed (e.g. '-cn' is invalid) !!!")
        println(usage)
        exit()
    end
    
    if a == "-n"
        nom, i = get_arg(ARGS, i)
        if ismatch(gooda, nom)
            println("ERROR: bad value '$nom' for flag '$a'")
            println(usage)
            exit()
        end
    elseif a == "-D"    # debbug
        debug = "true"
    elseif a == "-c"
        w_header = "true"
    else
        GSIZE = parse(ARGS[end]) # input file
    end
    i += 1
end

if debug == "true"
    println(ARGS)
    println("-n=$nom; -c=$w_header; Gsize=$GSIZE")
#~    exit()
end

if GSIZE == "" 
    println("ERROR: Gsize not given")
    println("Flag values are: -n=$nom; -c=$w_header; Gsize=$GSIZE")
    exit()
end

## real stuff
som = 0
ite = 0
println(STDERR, "## Process $nom")
i=1
if w_header == "true"
    gsiz= GSIZE / 1e6
    println("Sample\tN_reads\tNbases (Mb)\tMeanLength\tDoS (Gsize=$(gsiz)Mb)")
end

for l in eachline(STDIN)
    if (l[1] == '@') & (%(i, 4) == 1)   # start only if sequence header
        l = readline(STDIN) # then read next line and compute length on it
        
        i+=1
        som += length(strip(l))
        ite += 1
        
        if ite % 1e5 == 0
            println(STDERR, ite)
        end
    end
    i+=1
    continue
end

cov = som / GSIZE
println(nom,"\t", ite, "\t", som/1e6, "\t", som/ite, "\t", cov)
