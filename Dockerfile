FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

RUN apt-get update && \
    apt-get install -y \
        software-properties-common && \
    apt-add-repository multiverse && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        g++ \
        make \
        automake \
        bzip2 \
        unzip \
        wget \
        sox \
        libtool \
        git \
        subversion \
        python2.7 \
        python3 \
        zlib1g-dev \
        ca-certificates \
        gfortran \
        patch \
        ffmpeg \
        vim && \
    apt-get update && \
    yes | DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
        intel-mkl && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python2.7 /usr/bin/python

RUN git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /opt/kaldi && \
    cd /opt/kaldi/tools && \
    make -j $(nproc) && \
    cd /opt/kaldi/src && \
    ./configure --shared --use-cuda && \
    make depend -j $(nproc) && \
    make -j $(nproc) && \
    find /opt/kaldi  -type f \( -name "*.o" -o -name "*.la" -o -name "*.a" \) -exec rm {} \; && \
    rm -rf /opt/kaldi/.git

RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    wget https://raw.githubusercontent.com/wshilton/andrew/main/vaes/requirements.txt && \
    python get-pip.py && \
    python -m pip install --user -r ./requirements.txt && \
    python -m pip install --user notebook boost

RUN apt-get update && \
    apt-get install -y \
        libboost-all-dev \
        python2-dev \
        python3-dev

#TODO: Investigate binding issues in kaldi-python wrappers.
#Kaldi-python has seen no activity for about 6 years. An active alternative
#is https://github.com/pykaldi/pykaldi#.
#A type change, among other things, in Kaldi is responsible for a failed binding.
#Forking kaldi-python.

RUN git clone https://github.com/wshilton/kaldi-python.git /opt/kaldi-python && \
    cd /opt/kaldi-python && \
    KALDI_ROOT=/opt/kaldi make all -j $(nproc) && \
    find /opt/kaldi-python  -type f \( -name "*.o" -o -name "*.la" -o -name "*.a" \) -exec rm {} \; && \
    rm -rf /opt/kaldi-python/.git
    
#ENV PATH=/root/.local/bin:$PATH

#CMD cd ./andrew/vaes/src &&\
#    jupyter notebook --ip 0.0.0.0 --no-browser --allow-root
