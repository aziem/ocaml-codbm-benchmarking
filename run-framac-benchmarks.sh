#!/bin/bash

DOUBLE=false
NUMRUNS=5
currentdir=`pwd`

APRONORIGDIR=$currentdir/apron-orig/
APRONAPLASDIR=$currentdir/apron-aplas-2017/
APRONSASDIR=$currentdir/apron-kent/

FRAMACDIR=$currentdir/frama-c-sulfur-kent

OUTPUTDIR=$currentdir/frama-c-results

FRAMACBENCHMARKSLOC=$currentdir/codbm-frama-c-benchmarks

RESULTTMPDIR=$currentdir/framacresultstmp/

# Use the following to run on the smaller benchmarks
#benchmarks=(solitaire/ 2048/ levenshtein.c/ mini-gmp/ khash/)
# or use the -s option
benchmarks=(solitaire/ 2048/ tiny-AES128-C/ levenshtein.c/ bzip-single-file/ libmodbus/ mini-gmp/ khash/)


#====================================
# Compilation functions
#====================================

compile_apron () {
    echo "Compiling Original Apron"
    cd ${APRONORIGDIR}
    # make clean && ./configure --no-java --no-ppl && make -j 2 && ./reinstall-apron.sh
    ./reinstall-apron.sh
    cd $currentdir
}

compile_hash () {
    echo "Compiling Seq No Strong"
    cd ${APRONSASDIR}/octagons; ./patchseqnostrong.sh; cd ..
    #make clean && ./configure --no-java --no-ppl && make -j 2 &&./reinstall-apron.sh
    ./reinstall-apron.sh
    cd $currentdir
}

compile_join_opt () {
    echo "Compiling Seq No Strong"
    cd ${APRONSASDIR}/octagons; ./patchseqnostrong-joinopt.sh; cd ..
    # make clean && ./configure --no-java --no-ppl && make -j 2 &&./reinstall-apron.sh
    ./reinstall-apron.sh
    cd $currentdir
}

compile_opt () {
    echo "Compiling Seq No Strong"
    cd ${APRONSASDIR}/octagons; ./patchseqnostrong-floydopt.sh; cd ..
    #  make clean && ./configure --no-java --no-ppl && make -j 2 &&./reinstall-apron.sh
    ./reinstall-apron.sh
    cd $currentdir
}

compile_aplas () {
    echo "Compiling APLAS CoDBM"
    cd $APRONAPLASDIR; make clean;
    #./configure --no-ppl --no-java && make -j 2 && ./reinstall-apron.sh
    ./reinstall-apron.sh
    cd $currentdir
}

compile_framac_mpq () {
    echo "Compiling Frama-C using Octagons MPQ"
    cd $FRAMACDIR; ./build-mpq.sh
}

compile_framac_double () {
    echo "Compiling Frama-C using Octagons doubles"
    cd $FRAMACDIR; ./build-double.sh
}


run_framac_benchmarks () {
    mkdir -p $RESULTTMPDIR
    for benchmark in "${benchmarks[@]}"
    do
     echo "Running $1 on ${benchmarksloc}/$benchmark"
     loc=${FRAMACBENCHMARKSLOC}/$benchmark
     name=$(echo ${benchmark} | awk -F"/" '{print $(NF-1)}')
     
     cd $loc; ./runeva.sh $NUMRUNS &> $RESULTTMPDIR/${name}$1.txt
     cat ${RESULTTMPDIR}/${name}$1.txt | grep -A1 user | awk '{print $2}' | awk '{sum+=$1} END {print sum}' > ${RESULTTMPDIR}/${name}$1-mean.txt
     cat ${RESULTTMPDIR}/${name}$1.txt | grep -A1 user | awk '{print $5}' | awk '{sum+=$1} END {print sum}' > ${RESULTTMPDIR}/${name}$1-median.txt
     echo "Done"
 done
}

process_results () {
    if [ "$DOUBLE" = true ] ; then
	rm frama-c-overall-results-dbl.txt
	for benchmark in "${benchmarks[@]}"
	do
	    name=$(echo ${benchmark} | awk -F"/" '{print $(NF-1)}')
	    paste <(echo $name) ${RESULTTMPDIR}/${name}aprondbl-mean.txt ${RESULTTMPDIR}/${name}aplasdbl-mean.txt ${RESULTTMPDIR}/${name}hashdbl-mean.txt ${RESULTTMPDIR}/${name}joinoptdbl-mean.txt ${RESULTTMPDIR}/${name}hashoptdbl-mean.txt >> frama-c-overall-results-dbl.txt
	done
    else
	rm frama-c-overall-results-mpq.txt
	for benchmark in "${benchmarks[@]}"
	do
	    name=$(echo ${benchmark} | awk -F"/" '{print $(NF-1)}')
	    echo $name
	    paste <(echo $name) ${RESULTTMPDIR}/${name}apronmpq-mean.txt ${RESULTTMPDIR}/${name}aplasmpq-mean.txt ${RESULTTMPDIR}/${name}hashmpq-mean.txt ${RESULTTMPDIR}/${name}joinoptmpq-mean.txt ${RESULTTMPDIR}/${name}hashoptmpq-mean.txt >> frama-c-overall-results-mpq.txt
	done
    fi
}


#====================================
# Functions to run benchmarks
#====================================
run_apron_benchmark () {
    compile_apron
    compile_framac_mpq
    run_framac_benchmarks apronmpq
}

run_apron_double_benchmark () {
    compile_apron
    compile_framac_double
    run_framac_benchmarks aprondbl
}

run_aplas_benchmark () {
    compile_aplas
    compile_framac_mpq
    run_framac_benchmarks aplasmpq 
}

run_aplas_double_benchmark () {
    compile_aplas
    compile_framac_double
    run_framac_benchmarks aplasdbl
}

run_hash_benchmark () {
    compile_hash
    compile_framac_mpq
    run_framac_benchmarks hashmpq
}

run_hash_double_benchmark () {
    compile_hash
    compile_framac_double
    run_framac_benchmarks hashdbl
}

run_join_opt_benchmark () {
    compile_join_opt
    compile_framac_mpq
    run_framac_benchmarks joinoptmpq
}

run_join_opt_double_benchmark () {
    compile_join_opt
    compile_framac_double
    run_framac_benchmarks joinoptdbl
}

run_opt_benchmark () {
    compile_opt
    compile_framac_mpq
    run_framac_benchmarks hashoptmpq
}

run_opt_double_benchmark () {
    compile_opt
    compile_framac_double
    run_framac_benchmarks hashoptdbl
}




#====================================
# Argument processing and execution
#====================================
while getopts ":hdsp" opt; do
    case ${opt} in
	h )
	    echo "Usage: "
	    echo "./run-framac-benchmarks.sh apron            Runs original Apron"
	    echo "./run-framac-benchmarks.sh aplas            Runs Aplas 2017 CoDBMs"
	    echo "./run-framac-benchmarks.sh hashing          Runs SAS 2018 CoDBMs with hashing"
	    echo "./run-framac-benchmarks.sh hashing_join     Runs SAS 2018 CoDBMs with hashing + join optimisation"
	    echo "./run-framac-benchmarks.sh hashing_opt      Runs SAS 2018 CoDBMs with hashing + join + closure optimisation"
	    echo "./run-framac-benchmarks.sh all              Run all versions of Apron in sequence"
	    echo " "
	    echo "Adding the -d option will select doubles. By default analysis is run using GMP MPQ rationals"
	    echo " "
	    echo "The results are written to files with the name of the benchmark followed by the Apron version used and whether mpq or doubles."
	    echo " "
	    echo "For example: ./run-framac-benchmarks.sh apron will result in files such as:"
	    echo "solitaireapronmpq-mean.txt"
	    echo "solitaireaplasmpq-median.txt"
	    echo "and raw timings in the file solitaireapronmpq.txt"
	    echo " "
	    echo " "
	    echo "Adding the -s option will run smaller benchmarks"
	    ;;
	d ) echo "Double option chosen"
	    DOUBLE=true
	    ;;
	s ) echo "Choosing smaller benchmarks"
	    benchmarks=(solitaire/ 2048/ levenshtein.c/ mini-gmp/ khash/)
	    ;;
	p ) echo "Processing"
	    process_results
	    ;;
	\? )
	    echo "Invalid option: -$OPTARG, use -h to see options" 1>&2
	    exit 1
	    ;;
    esac
done

shift $((OPTIND -1))

subcommand=$1

case "$subcommand" in
    apronorig )
	echo "Apron Original"
	if [ "$DOUBLE" = true ] ; then
	    echo "Running Double"
	    run_apron_double_benchmark
	else
	    echo "Running MPQ"
	    run_apron_benchmark
	fi
	;;
    aplas )
	echo "Aplas 2017 version (CoDBMs)"
	if [ "$DOUBLE" = true ] ; then
	    echo "Running Double"
	    run_aplas_double_benchmark
	else
	    echo "Running MPQ"
	    run_aplas_benchmark
	fi
	;;
    hashing )
	echo "SAS 2018 CoDBM with Hashing"
	if [ "$DOUBLE" = true ] ; then
	    echo "Running Double"
	    run_hash_double_benchmark
	else
	    echo "Running MPQ"
	    run_hash_benchmark
	fi
	;;
    hashing_join )
	echo "SAS 2018 CoDBM with Hashing + Join Optimisation"
	if [ "$DOUBLE" = true ] ; then
	    echo "Running Double"
	    run_join_opt_double_benchmark
	else
	    echo "Running MPQ"
	    run_join_opt_benchmark
	fi
	;;
    hashing_opt )
	echo "SAS 2018 CoDBM with Hashing + Join + Closure Optimisation"
	if [ "$DOUBLE" = true ] ; then
	    echo "Running Double"
	    run_opt_double_benchmark
	else
	    echo "Running MPQ"
	    run_opt_benchmark
	fi
	;;
    all )
	echo "Run benchmarks with all versions of Apron"
	if [ "$DOUBLE" = false ] ; then
	    echo "Running Apron"
	    run_apron_benchmark
	    echo "Running Aplas"
	    run_aplas_benchmark
	    echo "Running SAS 2018 Hash"
	    run_hash_benchmark
	    echo "Running SAS 2018 Hash + Join"
	    run_join_opt_benchmark
	    echo "Running SAS 2018 Hash + Join + Closure Optimisation"
	    run_opt_benchmark
	else
	    echo "Running Apron (Double)"
	    run_apron_double_benchmark
	    echo "Running Aplas (Double)"
	    run_aplas_double_benchmark
	    echo "Running SAS 2018 Hash (Double)"
	    run_hash_double_benchmark
	    echo "Running SAS 2018 Hash + Join (Double)"
	    run_join_opt_double_benchmark
	    echo "Running SAS 2018 Hash + Join + Closure Optimisation (Double)"
	    run_opt_double_benchmark
	fi
	;;
    \?)
	echo "Invalid option:" 
	exit 1
	;;
    :)
	echo "Invalid option"
	exit 1
	;;
esac
