FROM tiangolo/python-machine-learning:python3.6

LABEL maintainer="Malav Vyas <malavvyas98@gmail.com>"

RUN conda install tensorflow && conda install scikit-learn && conda install -c conda-forge keras && conda install matplotlib && pip install torch

#kaldi
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        make \
        automake \
        autoconf \
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
    rm -rf /var/lib/apt/lists/*

### Compile and install kaldi from repo ###

RUN git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /tmp/kaldi \
 && cd /tmp/kaldi/tools \
 && extras/install_mkl.sh \

 && make -j$(nproc) \
 && ln -s /usr/local/lib openfst/lib \
 && ln -s /usr/local/include openfst/include \
 && cd ../src \
 && ./configure \
 && make depend -j$(nproc) \
 && make -j$(nproc) \
 mv -t /usr/local/bin \

### Kaldi development files ###
 && cp -rp --parents */*.h /usr/local/include \
 && mkdir -p /usr/local/src \
 && cp -rp kaldi.mk makefiles /usr/local/src \
 && sed -i 's|/tmp/kaldi/tools/openfst|/usr/local|' /usr/local/src/kaldi.mk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
 RUN mkdir ~/openseq2seq && apt-get install git && git clone https://github.com/NVIDIA/OpenSeq2Seq


#persephone
RUN apt-get update && apt-get -y install \
	python3-pip \
	ffmpeg \
	wget \
	unzip \
	vim \
	sox

RUN pip3 install -U pip && pip3 install persephone && pip3 install ipython && conda update openssl ca-certificates certifi

ADD https://cloudstor.aarnet.edu.au/plus/s/YJXTLHkYvpG85kX/download data/

RUN mv data/download data/na_example_small.zip
RUN unzip data/na_example_small.zip -d data/ && rm data/na_example_small.zip

#pytorch-kaldi
RUN cd $HOME && git clone https://github.com/mravanelli/pytorch-kaldi && cd pytorch-kaldi && pip install blockdiag && pip install SpeechRecognition && cd ..

#kaldi-io
RUN python -m pip install kaldi_io && conda install -c conda-forge conda && conda install -c pykaldi pykaldi-cpu \
&& apt-get install -y --no-install-recommends protobuf-compiler libprotobuf-dev libsndfile1-dev nano cmake \
&& cd $HOME \
&& git clone https://github.com/espnet/espnet && cd espnet/tools && ls && make CUPY_VERSION='' -j 10 && conda install cupy

CMD [ "/bin/bash" ]
