FROM ubuntu:jammy as app

ARG PYCOQC_VER="2.5.2"

LABEL base.image="ubuntu:jammy"
LABEL dockerfile.version="1"
LABEL software="pycoqc"
LABEL software.version="${PYCOQC_VER}"
LABEL description="PycoQC computes metrics and generates interactive QC plots for Oxford Nanopore technologies sequencing data"
LABEL website="https://github.com/a-slide/pycoQC"
LABEL license="https://github.com/a-slide/pycoQC/blob/master/LICENSE"
LABEL maintainer="Dhatri Badri"
LABEL maintainer.email="dhatrib@umich.edu"

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget software-properties-common pkg-config && \
    apt-get install -y python3 python3-pip && \
    apt-get install -y libhdf5-dev && \
    pip3 install --upgrade pip && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/*

# Install Python packages from requirements.txt
COPY requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt
    
RUN wget -q https://github.com/a-slide/pycoQC/archive/${PYCOQC_VER}.tar.gz && \
    tar -xf ${PYCOQC_VER}.tar.gz && \
    ls -l && \   
    rm -v ${PYCOQC_VER}.tar.gz && \
    cd "pycoQC-${PYCOQC_VER}" && \
    ls -l && \   
    python3 setup.py build && \
    python3 setup.py install && \
    mkdir /data

# 'ENV' instructions set environment variables that persist from the build into the resulting image
# Use for e.g. $PATH and locale settings for compatibility with Singularity
ENV PATH="${PATH}:/pycoqc-${PYCOQC_VER}}/" \
    LC_ALL=C 

# 'WORKDIR' sets working directory
WORKDIR /data

# A second FROM insruction creates a new stage
FROM app as test

ARG PYCOQC_VER

WORKDIR /test

# cant get summary txt file     
RUN wget https://raw.githubusercontent.com/a-slide/pycoQC/master/docs/pycoQC/data/Albacore-1.2.1_basecall-1D-DNA_sequencing_summary.txt.gz && \
    gzip -d Albacore-1.2.1_basecall-1D-DNA_sequencing_summary.txt.gz && \
    pycoQC -f Albacore-1.2.1_basecall-1D-DNA_sequencing_summary.txt -o Albacore-1.2.1_basecall-1D-DNA_sequencing_summary.html

