#
# Copyright (c) 2022 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

export EXP_PATH=`dirname $0`
export EXP_NAME=examples/cpp/attestation

if [ -z ${BUILD_TYPE} ]; then
    export BUILD_TYPE=Debug
    export COMPILATION_MODE=dbg
fi

if [ -z ${SGX_RA_TLS_BACKEND} ]; then
    export SGX_RA_TLS_BACKEND=GRAMINE # GRAMINE,OCCLUM,TDX,DUMMY
fi

if [ -z ${SGX_RA_TLS_SDK} ]; then
    export SGX_RA_TLS_SDK=DEFAULT # DEFAULT,LIBRATS
fi

# build grpc package
${GRPC_PATH}/cmake_build_cpp.sh
# ${GRPC_PATH}/bazel_build_cpp.sh

# build c++ example
cd ${EXP_PATH}

mkdir -p build
cd build
touch .bazelignore
../generate_ssl.sh -s localhost -a my_ca
cp ${GRPC_PATH}/dynamic_config.json .
cp ../secret.json .
cd -

# build with cmake
cd build
cmake -D CMAKE_PREFIX_PATH=${INSTALL_PREFIX} \
      -D CMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -D GRPC_AS_SUBMODULE=OFF \
      -D GRPC_FETCHCONTENT=OFF ..
make -j `nproc`
cd -

# build with bazel
# bazel build :all -c dbg
# cp ${GRPC_PATH}/bazel-bin/${EXP_NAME}/server ${GRPC_PATH}/bazel-bin/${EXP_NAME}/client build

cd -
