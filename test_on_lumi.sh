#!/bin/bash

set -eu

sw=/project/project_465000454/icon/sw
container=/scratch/project_465000454/cpe/ccpe-rocm-5.4.1-16.0.1.1.sif

container_cmd="singularity exec --cleanenv --rocm --bind ${sw} ${container}"

module --force purge

init_python=yes
${container_cmd} bash -i - <<EOF
set -eu
test "x$init_python" = xno || {
  module load cray-python
  python -m venv python
  ./python/bin/python -m pip install --upgrade pip
  ./python/bin/python -m pip install numpy netCDF4 xarray dask[array]
}
module switch cce cce/16.0.1.1
module switch craype-x86-spr craype-x86-milan
module load craype-accel-amd-gfx90a rocm cray-netcdf
./configure --enable-gpu --enable-tests FC=ftn PYTHON=$(pwd)/python/bin/python
make -j8 check TESTS=
make .testcache/.dirstamp CURL=${sw}/gcc-12.2.0-zen2/curl-7.79.0/bin/curl
EOF

srun \
  --account=project_465000454 \
  --partition=small-g \
  --nodes=1 \
  --gpus-per-node=1 \
  --time=00:01:00 \
  ${container_cmd} bash -i - <<EOF
module load rocm
make check
EOF
