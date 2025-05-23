FROM nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04 as cuda11
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

FROM linuxserver/webtop:ubuntu-mate


COPY --from=cuda11 /usr/local/cuda-11.3 /usr/local/cuda-11.3
RUN cd /usr/local && ln -s cuda-11.3 cuda
RUN cd /usr/local && ln -s cuda-11.3 cuda-11

COPY --from=cuda11 \
   /usr/lib/x86_64-linux-gnu/libcudnn* \
   /usr/lib/x86_64-linux-gnu/

COPY --from=cuda11 \
   /usr/include/cudnn* \
   /usr/include/



ENV PATH="${PATH}:/usr/local/cuda/bin"
ENV CUDADIR="/usr/local/cuda"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda/lib64"






RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
        apt-utils \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        libfreetype6-dev \
        protobuf-compiler \
        python3-dev \
        python3-pip \
        python3-setuptools \
        gcc-9 \
        g++-9
   

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 1
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-9 1
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 1
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-9 1


ENV PIP_ROOT_USER_ACTION=ignore

RUN pip3 install Cython>=0.19.2 
RUN pip3 install scipy>=0.13.2 
RUN pip3 install scikit-image>=0.9.3 
RUN pip3 install "python-dateutil>=1.4,<2" 
RUN pip3 install matplotlib>=1.3.1 
RUN pip3 install ipython>=3.0.0 
RUN pip3 install h5py>=2.2.0 
RUN pip3 install leveldb>=0.191 
RUN pip3 install networkx>=1.8.1 
RUN pip3 install nose>=1.3.0 
RUN pip3 install pandas>=0.12.0 
RUN pip3 install protobuf==3.20.1
RUN pip3 install python-gflags>=2.0 
RUN pip3 install pyyaml>=3.10 
RUN pip3 install Pillow>=2.3.0 
RUN pip3 install six>=1.1.0
RUN pip3 install opencv-python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

RUN export PATH=$PATH:/usr/local/cuda/bin
RUN export CUDADIR=/usr/local/cuda
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64




COPY ./prerequisite/openpose /opt/openpose
ENV OPENPOSE_ROOT=/opt/openpose
WORKDIR $OPENPOSE_ROOT

RUN mkdir build && cd build && \
    cmake -DBUILD_PYTHON=ON -DBUILD_CAFFE=ON -DBUILD_PYTHON=ON .. && \
    make -j `nproc`

RUN cp -r ./build/python/openpose/ /usr/local/lib/python3.10/dist-packages/
RUN cp -r ./build/caffe/python/caffe/ /usr/local/lib/python3.10/dist-packages/



COPY ./humor /opt/humor
ENV HUMOR_ROOT=/opt/humor
WORKDIR $HUMOR_ROOT


RUN apt-get install -y ffmpeg

#RUN pip3 install torchvision==0.7.0
RUN pip3 install torchvision==0.12.0
RUN pip3 install trimesh 
RUN pip3 install pyrender 
RUN pip3 install pyglet==1.5.15 
RUN pip3 install tensorboard
RUN pip3 install git+https://github.com/nghorbani/configer
RUN pip3 install torchgeometry==0.1.2
RUN pip3 install smplx==0.1.28
RUN pip3  install "numpy<1.24"

RUN mkdir /opt/humor/external/
RUN cp -r /opt/openpose /opt/humor/external/openpose
RUN chmode -R 777 /opt/humor




