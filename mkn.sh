#!/usr/bin/env bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exec 19>$CWD/.mkn.sh.cmd # set -x redirect
export BASH_XTRACEFD=19  # set -x redirect

set -xe
(
  date

  THREADS=${THREADS:=""}
  DIR="umpire"
  # TODO - change back to llnl upstream when it works
  GIT_URL="git@github.com:PhilipDeegan/umpire" #"https://github.com/llnl/$DIR"
  VERSION="phare" #"develop"
  FFF=("include" "lib" "$DIR" "share")
  [ ! -z "$MKN_CLEAN" ] && (( $MKN_CLEAN == 1 )) && for f in ${FFF[@]}; do rm -rf $CWD/$f; done
  [ ! -d "$CWD/$DIR" ] && git clone --depth 1 $GIT_URL -b $VERSION $DIR --recursive

  cd $CWD/$DIR

  rm -rf build && mkdir build && cd build

  CMAKE_CXX_FLAGS="-g0 -O3 -march=native -mtune=native -fPIC"
  CMAKE_CUDA_CLANG_FLAGS="-x cuda --cuda-gpu-arch=sm_61 -std=c++17"
  CMAKE_CUDA_FLAGS="" #${CMAKE_CUDA_CLANG_FLAGS}"

  cmake .. -DCMAKE_INSTALL_PREFIX=$CWD          \
    -DUMPIRE_ENABLE_EXAMPLES=OFF                \
    -DENABLE_EXAMPLES=OFF                       \
    -DENABLE_TESTS=OFF                          \
    -DENABLE_CUDA=ON -DENABLE_NUMA=ON           \
    -DENABLE_DEVELOPER_DEFAULTS=On              \
    -DCMAKE_CUDA_ARCHITECTURES=61               \
    -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}"      \
    -DCMAKE_CUDA_FLAGS="${CMAKE_CUDA_FLAGS}"    \
    -DBUILD_SHARED_LIBS=ON                      \

#    -DCMAKE_CUDA_COMPILER=clang++               \
#    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda     \
#    -DCMAKE_CUDA_COMPILER_TOOLKIT_ROOT=/usr/local/cuda \
#    -DCMAKE_CUDA_COMPILER_ID_RUN=1              \
#    -DCMAKE_CUDA_COMPILER_FORCED=1              \

  #   -DCMAKE_BUILD_TYPE=Release                              \
  #   -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true


  make VERBOSE=1 -j$THREADS && make install
  #cd .. && rm -rf build
  #find $CWD -maxdepth 1 -size 0 -name ".mkn.sh.*" -delete
  date
) 1> >(tee $CWD/.mkn.sh.out ) 2> >(tee $CWD/.mkn.sh.err >&2 )


