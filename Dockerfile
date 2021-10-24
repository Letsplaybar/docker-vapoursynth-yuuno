FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PYTHONPATH=/usr/local/lib/python3.8/site-packages

RUN apt update && \
    apt install -y build-essential autoconf automake autotools-dev libtool pkg-config curl git xz-utils cython3 nasm \
    yasm libtool pkg-config libfftw3-dev libpng-dev libsndfile1-dev libxvidcore-dev libbluray-dev zlib1g-dev \
    libopencv-dev ocl-icd-libopencl1 opencl-headers libboost-filesystem-dev libboost-system-dev ffmpeg python3 \
    python3-pip ninja-build meson && \
    pip3 -q install pip --upgrade && \
    pip3 install jupyter && \
    pip install yuuno && \
    yuuno jupyter install && \
    mkdir /jupyter && \
    ln -s /usr/bin/python3 /usr/bin/python

# zimg library
RUN git clone https://github.com/sekrit-twc/zimg.git /usr/src/zimg && \
    cd /usr/src/zimg && \
    ./autogen.sh && \
    ./configure && \
    make -j4 && \
    make install

# vapoursynth
RUN git clone https://github.com/vapoursynth/vapoursynth.git /usr/src/vapoursynth && \
    cd /usr/src/vapoursynth && \
    git checkout tags/R57 && \
    ./autogen.sh && \
    ./configure -enable-plugins && \
    make -j4 && \
    make install

#vapoursyth-plugins
RUN git clone --recurse-submodules -j8 https://github.com/Letsplaybar/vapoursynth-plugins.git /usr/src/vapoursynth-plugins && \
    cd /usr/src/vapoursynth-plugins && \
    make -j4

WORKDIR /jupyter

VOLUME /jupyter

EXPOSE 8888/tcp

#Run Command
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]