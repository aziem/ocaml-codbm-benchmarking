#!/bin/bash

DOUBLE=false
NUMRUNS=5
currentdir=`pwd`

APRONORIGDIR=$currentdir/apron-orig/
APRONAPLASDIR=$currentdir/apron-aplas-2017/
APRONSASDIR=$currentdir/apron-kent/

FUNCTIONLOC=$currentdir/function/
MULTITIME=/usr/local/bin/multitime

files=$(ls $FUNCTIONLOC/tests/*.c)

#====================================
# Compilation functions
#====================================

compile_apron () {
    echo "Compiling Original Apron"
    cd ${APRONORIGDIR}
    make clean && ./configure --no-java --no-ppl && make -j 30 && ./reinstall-apron.sh
    cd $currentdir
}

compile_hash () {
    echo "Compiling Seq No Strong"
    cd ${APRONSASDIR}/octagons; ./patchseqnostrong.sh; cd ..
    make clean && ./configure --no-java --no-ppl & make -j 30 &&./reinstall-apron.sh
    cd $currentdir
}

compile_join_opt () {
    echo "Compiling Seq No Strong"
    cd ${APRONSASDIR}/octagons; ./patchseqnostrong-joinopt.sh; cd ..
    make clean && ./configure --no-java --no-ppl && make -j 30 &&./reinstall-apron.sh
    cd $currentdir
}

compile_opt () {
    echo "Compiling Seq No Strong"
    cd ${APRONSASDIR}/octagons; ./patchseqnostrong-floydopt.sh; cd ..
    make clean && ./configure --no-java --no-ppl && make -j 30 &&./reinstall-apron.sh
    cd $currentdir
}

compile_aplas () {
    echo "Compiling APLAS CoDBM"
    cd $APRONAPLASDIR; make clean;
    ./configure --no-ppl --no-java && make -j 30 && ./reinstall-apron.sh
    cd $currentdir
}

compile_function_mpq () {
    echo "Compiling function using Octagons MPQ"
    cd $FUNCTIONLOC; make clean; ./patchmpq.sh; make; cd $currentdir
}

compile_function_double () {
    echo "Compiling function using Octagons double"
    cd $FUNCTIONLOC; make clean; ./patchdouble.sh; make; cd $currentdir
}

run_benchmark () {
    # Argument 1 is the apron implementation: apron, aplas, hash, join, hashopt
    # Argument 2 is either mpq or dbl (the number system to use)
    cd $FUNCTIONLOC
    echo "Running benchmarks $1"
    for f in $files; do
        echo "Running on file $f"
        $MULTITIME -n $NUMRUNS -q ./function $f -termination -domain octagons -joinbwd 2 -retrybwd 5 &> $f.multitime.$2.$1
        # get the mean time
        cat $f.multitime.$2.$1 | grep -A1 user | awk '{print $2}' | awk '{sum+=$1} END {print sum}' > ${f}.$1-mpq-mean.txt
        # get the median time
        cat $f.multitime.$2.$1 | grep -A1 user | awk '{print $5}' | awk '{sum+=$1} END {print sum}' > ${f}.$1-mpq-median.txt
    done
    cd $currentdir
}

run_apron_benchmark () {
    compile_apron
    compile_function_mpq
    run_benchmark apron mpq
}

run_apron_double_benchmark () {
    compile_apron
    compile_function_double
    run_benchmark apron dbl
}

run_aplas_benchmark () {
    compile_aplas
    compile_function_mpq
    run_benchmark aplas mpq
}

run_aplas_double_benchmark () {
    compile_aplas
    compile_function_double
    run_benchmark aplas dbl
}

run_hash_benchmark () {
    compile_hash
    compile_function_mpq
    run_benchmark hash mpq
}

run_hash_double_benchmark () {
    compile_hash
    compile_function_double
    run_benchmark hash dbl
}

run_join_opt_benchmark () {
    compile_join_opt
    compile_function_mpq
    run_benchmark joinopt mpq
}

run_join_opt_double_benchmark () {
    compile_join_opt
    compile_function_double
    run_benchmark joinopt dbl
}

run_opt_benchmark () {
    compile_opt
    compile_function_mpq
    run_benchmark opt mpq
}

run_opt_double_benchmark () {
    compile_opt
    compile_function_double
    run_benchmark opt dbl
}


process_results () {
    echo "processing results"
    for f in $files; do
	if [ "$DOUBLE" = false ] ; then
	    rm function-overall-results-mpq-mean.txt
	    paste <(echo $f) ${f}.apron-mpq-mean.txt  ${f}.aplas-mpq-mean.txt ${f}.hash-mpq-mean.txt ${f}.joinopt-mpq-mean.txt ${f}.opt-mpq-mean.txt >> function-overall-results-mpq-mean.txt
	else
	    rm function-overall-results-dbl-mean.txt
            paste <(echo $f) ${f}.apron-dbl-mean.txt  ${f}.aplas-dbl-mean.txt ${f}.hash-dbl-mean.txt ${f}.joinopt-dbl-mean.txt ${f}.opt-dbl-mean.txt >> function-overall-results-dbl-mean.txt
	    
	fi
    done
}

while getopts ":hdp" opt; do
    case ${opt} in
	h )
	    echo "Usage: "
	    echo "./run-function-benchmarks.sh apron            Runs original Apron"
	    echo "./run-function-benchmarks.sh aplas            Runs Aplas 2017 CoDBMs"
	    echo "./run-function-benchmarks.sh hashing          Runs SAS 2018 CoDBMs with hashing"
	    echo "./run-function-benchmarks.sh hashing_join     Runs SAS 2018 CoDBMs with hashing + join optimisation"
	    echo "./run-function-benchmarks.sh hashing_opt      Runs SAS 2018 CoDBMs with hashing + join + closure optimisation"
	    echo "./run-function-benchmarks.sh all              Run all versions of Apron in sequence and process results"
	    echo " "
	    echo "Adding the -d option will select doubles. By default analysis is run using GMP MPQ rationals"
	    echo " "
	    echo "The results are written to files with the name of the benchmark followed by the Apron version used and whether mpq or doubles."
	    echo " "
	    echo "For example: ./run-function-benchmarks.sh apron will result in files such as:"
	    echo "<C file>-apron-mpq-mean.txt"
	    echo "<C file>-apron-mpq-median.txt"
	    echo "and raw timings in the file <C file>.multitime.mpq.apron"
	    echo " "
	    echo "-p option will process the results this only works after running each version of Apron"
	    echo "and will output overall-results-mpq-mean.txt or overall-results-dbl-mean.txt depending on the double option choice"
	    ;;
	d ) echo "Double option chosen"
	    DOUBLE=true
	    ;;
	p ) echo "Processing results"
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
    apron )
	echo "Apron Original"
	if [ "$DOUBLE" = true ] ; then
	    echo "Running double"
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
	    echo "Processing results"
	    process_results
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
	    echo "Processing results"
	    process_results
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




