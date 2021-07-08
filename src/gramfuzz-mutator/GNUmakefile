CUR_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: gramfuzz-mutator.so

# These can be overriden:
CFLAGS	?= $(CFLAGS_FLTO)

# These are required: (otherwise radamsa gets very very slooooow)
CFLAGS	+= -O3 -funroll-loops
# CFLAGS	+= -O0 -g
# CFLAGS += $(shell pkg-config --cflags json-c)

LDFLAGS += $(shell pkg-config --libs json-c)
LDFLAGS += -Wl,-R/usr/local/lib

OBJ = gramfuzz.o gramfuzz-helpers.o gramfuzz-mutators.o gramfuzz-util.o hashmap.o

gramfuzz-mutator.so: $(OBJ) 
	$(CC) $(CFLAGS) -shared -fPIC -o gramfuzz-mutator.so $^ 

%.o: %.c $(DEPS)
	$(CC) -I. -I../afl-gf/include/ -fPIC -c -o $@ $< $(LDFLAGS) $(CFLAGS)

test: test.c
	$(CC)  -I. -I../afl-gf/include/ gramfuzz-helpers.c gramfuzz-mutators.c gramfuzz-util.c test.c -o test $(LDFLAGS) $(CFLAGS)

clean:
	rm -f gramfuzz-mutator.so *.o *~ core

testclean:
	rm -f test

benchmarkclean:
	rm -f benchmark
