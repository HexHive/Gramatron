#!/bin/bash

AFL_GF=`pwd`/afl-gf
GF_MUTATOR=`pwd`/gramfuzz-mutator
CLANG=clang
CLANGXX=clang++
LLVM_CONFIG=llvm-config

export CC=$CLANG
export CXX=$CLANGXX
export LLVM_CONFIG=$LLVM_CONFIG

# get AFL (used for Gramatron modifications)
if [ ! -d afl-gf ]; then
git clone https://github.com/AFLplusplus/AFLplusplus afl-gf 
cd afl-gf && git reset --hard 4a51cb7 && cd -
fi

# Link Gramfuzz-specific modifications into the repo
ln -s `pwd`/gramfuzz-mutator $AFL_GF/custom_mutators/gramfuzz

rm $AFL_GF/include/afl-fuzz.h
ln -s `pwd`/include_AFL/afl-fuzz.h $AFL_GF/include/afl-fuzz.h

rm $AFL_GF/include/envs.h
ln -s `pwd`/include_AFL/envs.h $AFL_GF/include/envs.h


ln -s `pwd`/include_AFL/gramfuzzer.h $AFL_GF/include/gramfuzzer.h
ln -s `pwd`/include_AFL/hashmap.h $AFL_GF/include/hashmap.h
ln -s `pwd`/include_AFL/utarray.h $AFL_GF/include/utarray.h
ln -s `pwd`/include_AFL/uthash.h $AFL_GF/include/uthash.h

rm $AFL_GF/src/afl-fuzz-init.c
ln -s `pwd`/src_AFL/afl-fuzz-init.c $AFL_GF/src/afl-fuzz-init.c

rm $AFL_GF/src/afl-fuzz-state.c
ln -s `pwd`/src_AFL/afl-fuzz-state.c $AFL_GF/src/afl-fuzz-state.c

rm $AFL_GF/src/afl-fuzz.c
ln -s `pwd`/src_AFL/afl-fuzz.c $AFL_GF/src/afl-fuzz.c

rm $AFL_GF/src/afl-fuzz-one.c
ln -s `pwd`/src_AFL/afl-fuzz-one.c $AFL_GF/src/afl-fuzz-one.c

rm $AFL_GF/GNUmakefile
ln -s `pwd`/GNUmakefile_AFL $AFL_GF/GNUmakefile

cd $AFL_GF
make -C custom_mutators/gramfuzz
make 
make -C llvm_mode
cd -
cd $GF_MUTATOR
make test 
cd -
