#!/bin/bash
set -e -v -x

SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"

source ${SCRIPT_DIR}/init.sh

cookiecutter \
   --replay-file ${TEST_DIR}/cc-replay/fpm-mpi.json\
    ${COOKIECUTTER_ROOT_DIR}

fpm build -C testproject
fpm test -C testproject --verbose
fpm run -C testproject --target testproject_app
fpm run -C testproject --example testproject_example
fpm install -C testproject --prefix ${PWD}/_install
mpirun -n 2 ./_install/bin/testproject_app

cp -a ${TEST_DIR}/testers/export_test.mpi export_test
cp export_test/fpm.toml.in export_test/fpm.toml
echo "testproject = { path = \"../testproject\"}" >> export_test/fpm.toml
fpm build -C export_test
fpm run -C export_test --target export_test
