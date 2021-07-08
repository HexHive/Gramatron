# Gramatron

Gramatron is a coverage-guided fuzzer that uses grammar automatons to perform
grammar-aware fuzzing.  Technical details about our framework are available in our
[ISSTA'21 paper](https://nebelwelt.net/files/21ISSTA.pdf). The artifact to reproduce the
experiments presented in our paper are present in `artifact/`. Instructions to run
a sample campaign and incorporate new grammars is presented below: 


# Run a sample fuzz campaign

- Pull the docker image and spawn a shell inside it
```
docker pull prashast94/gramatron:latest
docker run --security-opt seccomp=unconfined -it gramatron:latest /bin/bash
```

- Setup a test target
```
cd gramfuzz-mutator
./create_sample_target.sh
```
- Run a fuzz campaign using Gramatron.
```
./run_campaign.sh ~/grammars/ruby/source_automata.json test_output "/tmp/mruby/bin/mruby @@"
```
    - You should see the campaign start up with a UI screen displaying the campaign in progress
    - Validate that the `new edges on` row  under `findings in depth` has a non-zero number to sanity check 
      that the campaign is progressing as expected
    - After validating exit the fuzzing campaign using `Ctrl-C` 

# Adding and testing a new grammar

- Specify in a JSON format for CFG. Examples are correspond `source.json` files 
- Run the automaton generation script (in `src/gramfuzz-mutator/preprocess`)
  which will place the generated automaton in the same folder.
```
./prep_automaton.sh <grammar_file> <start_symbol> [stack_limit]

Eg. ./prep_automaton.sh ~/grammars/ruby/source.json PROGRAM
```
- If the grammar has no self-embedding rules then you do not need to pass the
  stack limit parameter. However, if it does have self-embedding rules then you
  need to pass the stack limit parameter. We recommend starting with `5` and
  then increasing it if you need more complexity
- To sanity-check that the automaton is generating inputs as expected you can use the `test` binary housed in `src/gramfuzz-mutator`
```
./test SanityCheck <automaton_file>

Eg. ./test SanityCheck ~/grammars/ruby/source_automata.json
```

# Installing from scratch

If instead of using the provided Dockerfile you want to install Gramatron from scratch follow the instructions below: 

- Install `json-c` 
```
git clone https://github.com/json-c/json-c.git
cd json-c && git reset --hard af8dd4a307e7b837f9fa2959549548ace4afe08b && sh autogen.sh && ./configure && make && make install
```
- Go into `src/` directory and run the `setup.sh` script
