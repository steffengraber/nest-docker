FROM buildpack-deps:bionic
LABEL maintainer="s.graber@fz-juelich.de"

ENV TERM=xterm \
    TZ=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libtool automake autotools-dev libreadline7 libreadline-dev freeglut3-dev \
    gosu \
    jq \
    libboost-all-dev \
	libgomp1 \
    libgsl-dev \
    libltdl7 \
    libltdl-dev \
    libmusic1v5 \
    libopenmpi-dev \
    libomp-dev \
    libblas3 \
    liblapack3 \
    libpsm-infinipath1 \
    libpcre3 \
    libpcre3-dev \
    libpython3.6 \
    llvm-dev \
    openmpi-bin \
    openssh-client \
    pep8 \
    libboost-all-dev \
    python3-matplotlib \
    python3-mpi4py \
    python3-numpy \
    python3-pandas \
    python3-path \
    python3-pip \
    python3-scipy \
    python3-setuptools \
    python3-statsmodels \
    python3-tk \
    vera++ \
    wget  && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    # update-alternatives --remove-all python && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 10 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10

RUN python3 -m pip install --upgrade pip  && \
      pip3 install cmake && \
      pip3 install Cython setuptools nose

# Install music
RUN wget https://github.com/INCF/MUSIC/archive/master.tar.gz && \
	tar -zxf master.tar.gz && \
	mkdir music-build music-install && \
	cd MUSIC-master && \
	sh ./autogen.sh && \
	cd ../music-build && \
	../MUSIC-master/configure --prefix=/opt/music-install && \
	make && \
	make install && \
	cd / && \
    rm master.tar.gz

# Install libneurosim
RUN git clone https://github.com/INCF/libneurosim.git libneurosim && \
    cd libneurosim && \
    git checkout 03646747c8fe64fa3439ac2d282623b659f60c22 && \
    chmod +x autogen.sh && \
    ./autogen.sh && \
    chmod +x configure && \
    ./configure --prefix=/opt/libneurosim-install --with-python=3 && \
    make && \
    make install


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
