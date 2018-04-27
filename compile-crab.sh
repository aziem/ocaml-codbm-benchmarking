#!/bin/bash
DOUBLE=false

CRABLLVMLOCATION=$HOME/tools/crab-llvm

CRABLLVMINSTALL_LOCATION=$HOME/crab-install

CRABLLVMINSTALL_LOCATION_APRON=$HOME/crab-apron
CRABLLVMINSTALL_LOCATION_APLAS=$HOME/crab-aplas
CRABLLVMINSTALL_LOCATION_HASH=$HOME/crab-hash
CRABLLVMINSTALL_LOCATION_HASHOPT=$HOME/crab-hash-opt

CRABLLVMINSTALL_LOCATION_APRON_DOUBLE=$HOME/crab-apron-double
CRABLLVMINSTALL_LOCATION_APLAS_DOUBLE=$HOME/crab-aplas-double
CRABLLVMINSTALL_LOCATION_HASH_DOUBLE=$HOME/crab-hash-double
CRABLLVMINSTALL_LOCATION_HASHOPT_DOUBLE=$HOME/crab-hash-opt-double

while getopts ":hd" opt; do
    case ${opt} in
	h )
	    echo "Usage: "
	    echo "./compile-crab.sh elina            Compiles Crab with Elina"
	    echo "./compile-crab.sh apron            Compiles Crab with Apron"
	    echo "./compile-crab.sh aplas            Compiles Crab with Aplas versrion of Apron"
	    echo "./compile-crab.sh hash             Compiles Crab with Hash version of Apron"
	    echo "./compile-crab.sh join             Compiles Crab with Hash + Join optimisation version of Apron"
	    echo "./compile-crab.sh opt              Compiles Crab with Hash + Join + Closure optimisation version of Apron"
	    echo "Adding -d option to the above will use doubles instead of MPQ rationals (in the case of Elina doubles is always used"
	    ;;
	d )
	    echo "Double option chosen"
	    DOUBLE=true
	    ;;
	\? )
	    echo "Invalid option: -$OPTARG" 1>&2
	    exit 1
	    ;;
    esac
done

compile_apron () {
    cd $CRABLLVMLOCATION
    mkdir -p $CRABLLVMINSTALL_LOCATION_APRON
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION_APRON -DUSE_APRON=ON -DUSE_APLAS=OFF -DUSE_APRON_ORIG=ON -DUSE_HASH=OFF -DUSE_HASH_OPT=OFF -DUSE_APRON_DOUBLE=OFF ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_apron_double () {
    cd $CRABLLVMLOCATION
    mkdir -p $CRABLLVMINSTALL_LOCATION_APRON_DOUBLE
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION_APRON_DOUBLE -DUSE_APRON=ON -DUSE_APLAS=OFF -DUSE_APRON_ORIG=ON -DUSE_HASH=OFF -DUSE_HASH_OPT=OFF -DUSE_APRON_DOUBLE=ON ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_aplas () {
    cd $CRABLLVMLOCATION
    mkdir -p $CRABLLVMINSTALL_LOCATION_APLAS
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION_APLAS -DUSE_APRON=ON -DUSE_APLAS=ON -DUSE_APRON_ORIG=OFF -DUSE_HASH=OFF -DUSE_HASH_OPT=OFF -DUSE_APRON_DOUBLE=OFF ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_aplas_double () {
    cd $CRABLLVMLOCATION
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION -DUSE_APRON=ON -DUSE_APLAS=ON -DUSE_APRON_ORIG=OFF -DUSE_HASH=OFF -DUSE_HASH_OPT=OFF -DUSE_APRON_DOUBLE=ON ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_hash () {
    cd $CRABLLVMLOCATION
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION -DUSE_APRON=ON -DUSE_APLAS=OFF -DUSE_APRON_ORIG=OFF -DUSE_HASH=ON -DUSE_HASH_OPT=OFF -DUSE_APRON_DOUBLE=OFF ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_hash_double () {
    cd $CRABLLVMLOCATION
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION -DUSE_APRON=ON -DUSE_APLAS=OFF -DUSE_APRON_ORIG=OFF -DUSE_HASH=ON -DUSE_HASH_OPT=OFF -DUSE_APRON_DOUBLE=ON ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_hash_opt () {
    cd $CRABLLVMLOCATION
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION -DUSE_APRON=ON -DUSE_APLAS=OFF -DUSE_APRON_ORIG=OFF -DUSE_HASH=OFF -DUSE_HASH_OPT=ON -DUSE_APRON_DOUBLE=OFF ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

compile_hash_opt_double () {
    cd $CRABLLVMLOCATION
    mkdir -p build && cd build
    rm -rf crab ../crab
    cmake -DCMAKE_INSTALL_PREFIX=$CRABLLVMINSTALL_LOCATION -DUSE_APRON=ON -DUSE_APLAS=OFF -DUSE_APRON_ORIG=OFF -DUSE_HASH=OFF -DUSE_HASH_OPT=ON -DUSE_APRON_DOUBLE=ON ../
    cmake --build . --target crab && cmake ..
    cmake --build . --target apron && cmake ..
    cmake --build . --target llvm && cmake ..
    cmake --build . --target install
}

# echo "COMPILING APRON"
# compile_apron
# echo "COMPILING APRON DBL"
# compile_apron_double
echo "COMPILING APLAS"
compile_aplas
# echo "COMPILING APLAS DBL"
# compile_aplas_double
# echo "COMPILING HASH"
# compile_hash
# echo "COMPILING HASH DBL"
# compile_hash_double
# echo "COMPILING HASH OPT"
# compile_hash_opt
# echo "COMPILING HASH OPT DBL"
# compile_hash_opt_double


