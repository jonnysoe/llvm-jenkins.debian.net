# Installation tests

This folder contains a set of tests for the [llvm.sh](../llvm.sh) installation script. These tests ensure that the script works on the different Linux distributions and versions.

## Prerequisite(s)
* [Docker](https://docs.docker.com/engine/install/debian/#installation-methods)

## Running the tests

Steps to run the tests on a Linux machine:
1. run `git submodule update --init` as the tests depend on a bash automated test framework ([BATS](https://github.com/sstephenson/bats)).
2. Run [test.sh](./test.sh). This will create a logfile at `test.log`

NOTE: Just compare the `ok` or `not ok` output between the original and new `test.log` for now, the following command is a good start:
```
grep " - llvm" ./test.log
```

## How the tests work

[test.sh](./test.sh) will generate a test suite in the file `test.bats` and then use BATS to execute the test suite. [BATS](https://github.com/sstephenson/bats) is a test framework for bash scripts.

The test suite consists of one test case for every supported Linux distribution version and llvm version. Right now there are 27 test cases. Each test case consists of these steps:
1. Create docker container with default distro image
2. Install a selection of llvm tools in the docker container
3. Compile and run a small C++ project

A test case succeeds iff the docker container can be built successfully and the installed clang tools work.
