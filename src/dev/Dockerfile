FROM docker-registry.ebrains.eu/nest/nest-simulator:nest-simulator-build-base as builder
LABEL maintainer="s.graber@fz-juelich.de"

ARG NEST_VERSION=master
ARG SRC_PATH=/tmp

# Install NEST and NESTML
RUN wget https://github.com/nest/nest-simulator/archive/refs/heads/${NEST_VERSION}.tar.gz -P ${SRC_PATH} && \
    cd ${SRC_PATH} && tar -xzf ${NEST_VERSION}.tar.gz && ls -l && \
    python3 -m pip install -r ${SRC_PATH}/nest-simulator-${NEST_VERSION}/doc/requirements.txt && \
    python3 -m pip install sphinx_gallery==0.10.1

ENV CONDA_DIR=/opt/conda

# Update system
RUN apt-get update && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH 




COPY environment.yml environment.yml
RUN conda env create --name nest --file environment.yml \
    && conda init bash

RUN echo "conda activate nest" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Installing build support
# Not used in cmake, so do not to install
# RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_music.sh 
# RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_sionlib.sh

ENV PYLIB_DIR=/opt/conda/env/include/lib

#-Dwith-sionlib='$HOME/.cache/sionlib.install' \
#ENV CMAKE_C_COMPILER_LAUNCHER=ccache
#ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
#ENV CXX_FLAGS="-pedantic -Wextra -Wno-unknown-pragmas -D_GLIBCXX_ASSERTIONS"
#-DCMAKE_CXX_FLAGS="$CXX_FLAGS" 
# Download  NEST 
RUN wget https://github.com/nest/nest-simulator/archive/refs/heads/${NEST_VERSION}.tar.gz -P ${SRC_PATH} \
    && cd ${SRC_PATH} && tar -xzf ${NEST_VERSION}.tar.gz 
    
RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_csa-libneurosim.sh $PYLIB_DIR \
    && mkdir nest-build && cd nest-build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/nest \              
          -Dwith-warning=ON \
          -Dwith-userdoc=ON \
          -Dwith-boost=ON \
          -Dwith-ltdl=ON \
          -Dwith-gsl=ON \
          -Dwith-readline=ON \
          -Dwith-python=ON \
          -Dwith-mpi=ON \
          -Dwith-openmp=ON \
          -Dwith-music=OFF \
          -Dwith-hdf5=ON \
          -Dwith-sionlib=OFF \
          -Dwith-libneurosim=$HOME/.cache/libneurosim.install \
          ${SRC_PATH}/nest-simulator-${NEST_VERSION} \
&& make -j $(nproc) VERBOSE=1 \
&& make docs \
&& make install \
&& mkdir -p $HOME/.matplotlib \
&& echo "backend : svg" > $HOME/.matplotlib/matplotlibrc \
&& python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir jupyter notebook && \
    python3 -m pip install --no-cache-dir quantities lazyarray neo && \
    python3 -m pip install --no-cache-dir --no-binary :all: PyNN && \
    python3 -m pip install --no-cache-dir elephant[extras] && \
    python3 -m pip install --no-cache-dir MarkupSafe==2.0.1 && \ 
    python3 -m pip install --no-cache-dir nest-desktop --pre && \
    python3 -m pip install --no-cache-dir https://github.com/nest/nestml/archive/refs/heads/master.zip --upgrade

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install nest-desktop --pre && \
    python3 -m pip uninstall nestml -y && \
    python3 -m pip install https://github.com/nest/nestml/archive/refs/heads/master.zip --upgrade

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY test-nest.sh /opt/test-nest.sh
RUN chmod +x /opt/test-nest.sh

EXPOSE 8080 52425 54286
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
