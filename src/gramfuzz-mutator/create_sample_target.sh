# Create a sample target as a part of the getting-started phase

FUZZERDIR="/root/gramatron_src"
AFLCC="$FUZZERDIR/afl-gf/afl-clang-fast"
mruby_tmp() {
git clone https://github.com/mruby/mruby /tmp/mruby
cd /tmp/mruby
git checkout fabc460
echo $1
echo $2
AFL_USE_ASAN=1 AFL_CC=$1 CC=$2 LD=$2 make -j`nproc`
cd -
}
rm -rf /tmp/mruby
mruby_tmp "clang" "$AFLCC" 
