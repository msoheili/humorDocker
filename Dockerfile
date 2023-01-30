From nvidia/cuda:11.3.0-cudnn8-devel-ubuntu20.04
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
        python3-setuptools 
   
ENV CAFFE_ROOT=/opt/caffe
ENV PIP_ROOT_USER_ACTION=ignore

WORKDIR $CAFFE_ROOT

#RUN pip3 install --upgrade pip

RUN git clone --depth 1 https://github.com/BVLC/caffe.git .
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
RUN pip3 install protobuf>=2.5.0 
RUN pip3 install python-gflags>=2.0 
RUN pip3 install pyyaml>=3.10 
RUN pip3 install Pillow>=2.3.0 
RUN pip3 install six>=1.1.0
RUN ln -s /usr/bin/python3.8 /usr/bin/python


# change  
#file(READ ${CUDNN_INCLUDE}/cudnn.h CUDNN_VERSION_FILE_CONTENTS)
#into 
#file(READ ${CUDNN_INCLUDE}/cudnn_version.h CUDNN_VERSION_FILE_CONTENTS)
#in Cuda.cmake


#Cuda.cmake. On line 9 just get rid of 20 21(20) 30 on the list of known GPU architectures.


RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && make -j install && cd .. && rm -rf nccl && \ 
    mkdir build && cd build && \
    cmake -DUSE_CUDNN=1 -DUSE_NCCL=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace

