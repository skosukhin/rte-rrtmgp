#!/bin/bash

set -eux

work_dir='lumi'

mkdir "${work_dir}"
cd "${work_dir}"

module load cray-python
python -m venv python-venv
source python-venv/bin/activate
pip3 install --upgrade pip
pip3 install dask[array] netCDF4 numpy xarray

git clone --depth 1 https://github.com/earth-system-radiation/rte-rrtmgp.git
cd rte-rrtmgp
git clone --depth 1 https://github.com/earth-system-radiation/rrtmgp-data.git

module load PrgEnv-cray cce/16.0.1 craype-x86-milan craype-accel-amd-gfx90a rocm cray-hdf5 cray-netcdf

export FC='ftn'
export FCFLAGS='-hnoomp -hacc'
export RRTMGP_ROOT=$(pwd)
export RRTMGP_DATA="${RRTMGP_ROOT}/rrtmgp-data"
export RTE_KERNELS='accel'
export RUN_CMD='srun -G 1 -A project_465000454 -p dev-g -t 5:00'
export FAILURE_THRESHOLD='7.e-4'

make libs
make tests
make check
