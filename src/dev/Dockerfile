FROM ubuntu:jammy
LABEL maintainer="s.graber@fz-juelich.de"

ARG NEST_VERSION=master
ARG SRC_PATH=/tmp

ENV TERM=xterm \
    TZ=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive

ENV CONDA_DIR=/opt/conda

# Update system
RUN apt-get update && apt-get install -y \
        build-essential \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH 

# Download  NEST and install conda
RUN wget https://github.com/nest/nest-simulator/archive/refs/heads/${NEST_VERSION}.tar.gz -P ${SRC_PATH} \
    && cd ${SRC_PATH} && tar -xzf ${NEST_VERSION}.tar.gz \
    && ls -l \
    && conda create --name nestenv \
    && conda init bash
# conda env create --name nestenv --file  ${SRC_PATH}/nest-simulator-${NEST_VERSION}/environment.yml

# Make RUN commands use the new environment:
RUN echo "conda activate nestenv" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Installing environment file do work
# TODO: Fix environment file
RUN conda install -c conda-forge python pip \
    && conda install -c conda-forge cmake cython openmpi boost gsl>=1.11 libtool readline hdf5 \
    &&  conda install -c conda-forge pytest pytest-timeout pytest-xdist pytest-pylint pytest-mypy pytest-cov numpy pandas scipy mpi4py data-science-types h5py terminaltables pycodestyle rstcheck mypy cppcheck \
    &&  conda install -c conda-forge ipython matplotlib jupyter jupyterlab \
    &&  conda install -c conda-forge PyYAML assimulo breathe csvkit docutils doxygen mock nbsphinx numpydoc path.py pydot recommonmark sphinx sphinx_rtd_theme tqdm yamllint \
    &&  conda install -c conda-forge flask flask_cors gunicorn requests restrictedpython werkzeug \
    &&  conda install -c conda-forge junitparser clang-format \
    &&  conda install -c conda-forge graphviz setuptools \
    &&  python3 -m pip install --no-cache-dir sphinx_gallery==0.10.1 junitparser>=2 clang-format==13.0 example Image sphinx_autobuild sphinx-tabs sphinx_design sphinx-material sphinx-copybutton

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
RUN bash ${SRC_PATH}/nest-simulator-${NEST_VERSION}/build_support/install_csa-libneurosim.sh $PYLIB_DIR \
    && mkdir nest-build && cd nest-build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/nest \              
          -Dwith-warning=ON \
          -Dwith-devdoc=ON \
          -Dwith-optimize=ON \
          -Dwith-userdoc=ON \
          -Dwith-boost=ON \
          -Dwith-ltdl=ON \
          -Dwith-gsl=ON \
          -Dwith-readline=ON \
          -Dwith-python=ON \
          -Dwith-mpi=OFF \
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
    python3 -m pip install --no-cache-dir Flask --upgrade && \
    python3 -m pip install --no-cache-dir Flask-cors --upgrade && \
    python3 -m pip install --no-cache-dir RestrictedPython --upgrade && \
    python3 -m pip install --no-cache-dir MarkupSafe==2.0.1 && \
    python3 -m pip install --no-cache-dir gunicorn && \
    python3 -m pip install --no-cache-dir jupyterlab && \
    python3 -m pip install --no-cache-dir elephant[extras] && \
    python3 -m pip install --no-cache-dir MarkupSafe==2.0.1 && \ 
    python3 -m pip install --no-cache-dir nest-desktop --pre && \
    python3 -m pip install --no-cache-dir https://github.com/nest/nestml/archive/refs/heads/master.zip --upgrade

RUN  conda clean --all

COPY entrypoint-conda.sh /usr/local/bin/entrypoint-conda.sh
RUN chmod +x /usr/local/bin/entrypoint-conda.sh

COPY test-nest.sh /opt/test-nest.sh
RUN chmod +x /opt/test-nest.sh

EXPOSE 8080 52425 54286
ENTRYPOINT ["/usr/local/bin/entrypoint-conda.sh"]
