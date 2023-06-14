FROM ubuntu:jammy
LABEL maintainer="s.graber@fz-juelich.de"

ARG NEST_VERSION=master
ARG SRC_PATH=/tmp

ENV TERM=xterm \
    TZ=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive

# Update system
RUN apt-get update && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y build-essential \
    && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH 



# Download  NEST
RUN wget https://github.com/nest/nest-simulator/archive/refs/heads/${NEST_VERSION}.tar.gz -P ${SRC_PATH} && \
    cd ${SRC_PATH} && tar -xzf ${NEST_VERSION}.tar.gz && ls -l

# Create conda env adn install NEST requirements
RUN conda env create --name nestenv --file  ${SRC_PATH}/nest-simulator-${NEST_VERSION}/environment.yml
RUN conda activate nestenv

RUN conda install -c conda-forge graphviz setuptools
RUN python3 -m pip install sphinx_gallery==0.10.1

# Installing build support
RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_music.sh
RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_sionlib.sh

ENV PYLIB_DIR="$(python3 -c "import sysconfig; print(sysconfig.get_path('include'))" | sed 's/include/lib/')"
RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_csa-libneurosim.sh $PYLIB_DIR

ENV CMAKE_C_COMPILER_LAUNCHER=ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
ENV CXX_FLAGS="-pedantic -Wextra -Wno-unknown-pragmas -D_GLIBCXX_ASSERTIONS"

        

#    python3 -m pip install -r ${SRC_PATH}/nest-simulator-${NEST_VERSION}/doc/requirements.txt && \
#    python3 -m pip install sphinx_gallery==0.10.1

RUN mkdir nest-build && cd nest-build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/nest \
          -DCMAKE_CXX_FLAGS="$CXX_FLAGS" \
          -Dwith-optimize=ON \              
          -Dwith-warning=ON \
          -Dwith-userdoc=ON \
          -Dwith-devdoc=ON \
          -Dwith-boost=ON \
          -Dwith-ltdl=ON \
          -Dwith-gsl=ON \
          -Dwith-readline=ON \
          -Dwith-python=ON \
          -Dwith-mpi=ON \
          -Dwith-openmp=ON \
          -Dwith-music='$HOME/.cache/music.install' \
          -Dwith-hdf5=ON \
          -Dwith-sionlib='$HOME/.cache/sionlib.install' \
          -Dwith-libneurosim='$HOME/.cache/libneurosim.install' \
          ${SRC_PATH}/nest-simulator-${NEST_VERSION} && \
    make -j $(nproc) VERBOSE=1 && \
    make docs && \
    make install

# Configure matplotlib
RUN mkdir -p $HOME/.matplotlib
RUN echo "backend : svg" > $HOME/.matplotlib/matplotlibrc

# NESTml NEST Desktop
RUN python3 -m pip install --upgrade pip && \

    python3 -m pip install jupyter notebook && \
    python3 -m pip install quantities lazyarray neo && \
    python3 -m pip install --no-binary :all: PyNN && \
    python3 -m pip install Flask --upgrade && \
    python3 -m pip install Flask-cors --upgrade && \
    python3 -m pip install RestrictedPython --upgrade && \
    python3 -m pip install MarkupSafe==2.0.1 && \
    python3 -m pip install gunicorn && \
    python3 -m pip install jupyterlab && \
    python3 -m pip install elephant[extras] && \
    python3 -m pip install MarkupSafe==2.0.1 && \ 
    python3 -m pip install nest-desktop --pre && \
    python3 -m pip install https://github.com/nest/nestml/archive/refs/heads/master.zip --upgrade

COPY entrypoint-conda.sh /usr/local/bin/entrypoint-conda.sh
RUN chmod +x /usr/local/bin/entrypoint-conda.sh

COPY test-nest.sh /opt/test-nest.sh
RUN chmod +x /opt/test-nest.sh

EXPOSE 8080 52425 54286
ENTRYPOINT ["/usr/local/bin/entrypoint-conda.sh"]
