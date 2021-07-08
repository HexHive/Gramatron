This subfolder holds all the instructions required to reproduce the experiments as detailed in our whitepaper.

# Getting Started

## Setup docker and AFL++ prerequisites

- Install docker by following instructions for Ubuntu [here](https://docs.docker.com/engine/install/ubuntu/)
- After installation, configure Docker to make it run as a non-root user using instructions [here](https://docs.docker.com/engine/install/linux-postinstall/)
- Setup preferred runtime settings for AFL++ on top of which Gramatron is built (this requires sudo privilege)
The changes performed change the CPU scaling governor to `performance` and renames the core
file to be generated with the name `core`.
```
cd gramatron-artifact/fuzzers/gramfuzz-mutator
./setup_afl.sh
```

## Acquiring the image

- Pull the docker image from docker-hub and run it
```
docker pull prashast94/gramatron-artifact
docker run -d --name=gramatron_artifact --security-opt seccomp=unconfined -it prashast94/gramatron-artifact /bin/zsh
```
## Initial Setup [Estimated Time: 6 minutes]

- Drop a shell into the image 
```
docker exec -it gramatron_artifact /bin/zsh
```
- Compile the fuzzers that will be used in the eval along with helper binaries 
```
cd ~/gramatron-artifact/fuzzers
./setup.sh
```

## Run a sample fuzz campaign [Estimated Time: 4 minutes] 

- Create the automaton for a grammar 
```
cd ~/gramatron-artifact/fuzzers/gramfuzz-mutator/preprocess
./prep_automaton.sh ~/gramatron-artifact/grammars/microbenchmarks/ruby/source.json PROGRAM
```
- Sanity check that the automaton was correctly generated. The output should be a bunch of inputs
that are generated being piped to stdout. 
```
cd ~/gramatron-artifact/fuzzers/gramfuzz-mutator/
./test SanityCheck ~/gramatron-artifact/grammars/microbenchmarks/ruby/source_automata.json
```
- Setup a test target
```
cd ~/gramatron-artifact/fuzzers/gramfuzz-mutator
./create_sample_target.sh
```
- Run a fuzz campaign using Gramatron.
```
cd ~/gramatron-artifact/fuzzers/gramfuzz-mutator
./run_campaign.sh ~/gramatron-artifact/grammars/microbenchmarks/ruby/source_automata.json test_output "/tmp/mruby/bin/mruby @@"
```
    - You should see the campaign start up with a UI screen displaying the campaign in progress
    - Validate that the `new edges on` row  under `findings in depth` has a non-zero number to sanity check 
      that the campaign is progressing as expected
    - After validating exit the fuzzing campaign using `Ctrl-C` 

# Experiments

## Coverage 

- This will setup the coverage experiments as detailed in Section 6.1 addressing RQ1
- Create targets for coverage collection [Estimated time: 3 min]
```
cd ~/gramatron-artifact/experiments/cov/scripts
./create_targets.sh
```
- Sample 1000 inputs using all the different approaches as listed in Table-1 for each of the grammars [ Estimated Time: 2 min]
```
cd ~/gramatron-artifact/experiments/cov/scripts
./gen_inputs.sh 1000
```
    - Note that in the paper we sample 10000 inputs. However, in the interest
      of time we recommend sampling smaller number of inputs. You can tune the 
      number of inputs to generate by tuning the first argument to this script.

    - Since we are generating lesser number of inputs it is possible that statistical
    significance is not established (p>0.05) due to the sampling of lesser number of inputs.

    - If you are interested in recreating the exact numbers from the paper in
      Table-1 with statistical significance, you would need to run
      `./gen_inputs.sh 10000`. However, we do warn this full-fledged
      experiments takes a long time to run (approximately 12 person-hours) 

- Obtain coverage information for each of the runs from each approach [Estimated Time: 1hr 35min ]
```
cd ~/gramatron-artifact/experiments/cov/scripts
./get_cov.sh
```
- Aggregate the results from each run and perform statistical tests.
```
cd ~/gramatron-artifact/experiments/cov/scripts
./get_stats.sh
```
    - This outputs the median coverage for each approach as showcased in
      Table-1. Additionally it also reports the p-values for each approach as
      compared to Gramatron.  
    - If the limited experiment is being run (1000 inputs/approach) you will
      notice the coverage numbers are an approximation of the numbers reported
      in the Table-1 which is expected due to the smaller sample size.

## Perf Experiments

- This set of experiments showcase that Gramatron is efficient while performing
input generation and mutation and that it also performs more aggressive mutations.

- Generate inputs and collect the raw data for each of the different aspects as mentioned
in Table 2. [Estimated Time: 36 minutes]
```
cd ~/gramatron-artifact/experiments/perf
./run_microbenchmarks.sh 100
```
    - Note that in the paper we sample 1000 inputs for each bucket creating 8000 inputs for
      each grammar . However, in the interest of time we sample 100 inputs per bucket creating 800 inputs
      to get an approximation of the results.

    - To run the experiment at the same scale as presented in the paper you
      would need to run `./run_microbenchmarks.sh 1000`. Note that this will
      take around 24 person-hours to generate the raw experimental data.

- Perform statistical tests over the raw perf data and aggregate the results. This will regenerate
a close approximate of the results in Table 2.
```
cd ~/gramatron-artifact/experiments/perf
./calculate_stats.sh
```
- Note that for the splice operator we observe Gramatron outperform Nautilus.
As mentioned in the paper as well, this speedup occurs beacause the Splice
operator used by Nautilus is optimimized for the workload corresponding to
splicing an input against a fragment of inputs. While for Gramatron, the
workload is represented as splicing two inputs (which we benchmarked for)
because this how AFL++ gives the workload to us.

- The boxplots showcased in Figure 4 for the PHP grammar can be generated as follows:
```
cd ~/gramatron-artifact/experiments/perf
./create_boxes.sh
```
- The above script will put the boxplots in PDF format in `~/gramatron-artifact/results/perf/boxes/php`

## Ground-Truth bug experiments

- In this section, we detail how to reproduce the results from our ground truth based bug experiments.

- Create all the targets with ground truth bugs. This should populate a limited
set of targets in `~/gramatron-artifact/targets/` upon completion. [Estimated Time: 15 minutes ]
```
cd ~/gramatron-artifact/experiments/gt_bugs
./create_targets_limited.sh
```

- Deploy the beanstalk server which will act as the job queue manager
```
beanstalkd &
```
- Load the job queue with fuzzing jobs as specified in the config file.
```
cd ~/gramatron-artifact/experiments/gt_bugs
python3.6 run_ground_truth_campaign.py -c run-limited.json --numcores 15 --put
```
- We note that for this experiment we provide a limited run config (1-hour campaign for
one bug) that serves the sole purpose of sanity-checking the experimentation
framework and the results themselves are not meant to be interpreted because of
their limited nature.  This version of the experiment requires 15 cpu-hours to
run.

- Unload the job queue to occupy the available cores. Based on the passed
`numcores` argument the job scheduler will deploy the campaigns. We recommend
setting this argument to the number of cores that you have available - 1. So
if you have 16 cores available, we recommend setting this argument to 15. [Estimated Time: 1 hour assuming 15 cores available] 

- WARNING: Do not put `numcores` greater than the number of cores that you have available since it
may cause unintended side-effects.
```
python3.6 run_ground_truth_campaign.py -c run-limited.json --numcores 15 --get
```
- Once the campaigns end, we can identify and analyze the crashes to collect stats pertaining to the ground truth bugs.
The below command will recreate the Table 3 in the paper.
```
python3.6 retrieve_results.py -c crash-limited.json -o out_limited.json
```
- Unfortunately, we do not have a shortened version of the bug discovery experiment that
can be run to get a rough approximation of the results. Since fuzzing is a random process 
we can't really lower bound the time lesser than 24 hours to get an
approximation of the results as of now.  Therefore, the experiment as done in
the paper requires 3600 CPU-hours to complete. To run the full-fledged set of
experiments as done in the paper, (i) Flush the queue thrice to ensure no jobs
are in there, (ii) Compile all the fuzz targets, (iii) Deploy the fuzzing
jobs using `run-all.json`, and (iv) Analyze the fuzz results. as follows: 
```
cd ~/gramatron-artifact/experiments/gt_bugs

python3.6 run_ground_truth_campaign.py -c run-all.json --numcores 15 --flush
python3.6 run_ground_truth_campaign.py -c run-all.json --numcores 15 --flush
python3.6 run_ground_truth_campaign.py -c run-all.json --numcores 15 --flush

./create_targets_all.sh

python3.6 run_ground_truth_campaign.py -c run-all.json --numcores 15 --put
python3.6 run_ground_truth_campaign.py -c run-all.json --numcores 15 --get

python3.6 retrieve_results.py -c crash-all.json -o out_all.json
```

## Bugs in the wild

We link public reports to the 4 bugs that we have publicly disclosed as of now in `~/gramatron-artifact/experiments/new_bugs/notes.md`
