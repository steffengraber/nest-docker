#!/bin/bash
set -e

IP_ADDRESS=$(hostname --ip-address)
USER_ID=${LOCAL_USER_ID:-9001}

if [[ ! $(id -u nest) = $USER_ID ]]; then
	echo "UID : $USER_ID"
	adduser --disabled-login --gecos 'NEST' --uid $USER_ID --home /home/nest nest
	export HOME=/home/nest
fi

export MUSIC_ROOT_DIR=/opt/music-install
export MUSIC_ROOT=${MUSIC_ROOT_DIR}
MUSIC_PATH=${MUSIC_ROOT_DIR}
export LD_LIBRARY_PATH=${MUSIC_PATH}/lib:$LD_LIBRARY_PATH
export PATH=${MUSIC_PATH}/bin:$PATH
export CPATH=${MUSIC_PATH}/include:$CPATH
export PYTHONPATH=${MUSIC_PATH}/lib/python3.6/site-packages:$PYTHONPATH

if [[ ! -d /opt/data ]]; then
	mkdir /opt/data
fi

if [[ "$1" = 'build' ]]; then
    cd /opt/data
    mkdir /opt/build
    chown -R nest:nest /opt/build
    mkdir /opt/install
    chown -R nest:nest /opt/install
    cd /opt/build
    gosu nest cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/install \
                    -Dwith-optimize=OFF \
                    -Dwith-boost=ON \
                    -Dwith-ltdl=ON \
                    -Dwith-gsl=ON \
                    -Dwith-readline=ON \
                    -Dwith-python=3 \
                    -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
                    -DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
                    -Dwith-mpi=OFF \
                    -Dwith-openmp=ON \
                    -Dwith-libneurosim=/opt/libneurosim-install \
                    -Dwith-music=OFF \
                    /opt/data
    gosu nest make
    gosu nest make install
    gosu nest make installcheck
fi
