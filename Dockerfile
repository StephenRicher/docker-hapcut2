#################### BASE IMAGE ######################

FROM alpine:3.9 AS download

#################### METADATA ########################

LABEL base.image="alpine:3.9"
LABEL version="1"
LABEL software="HapCUT2"
LABEL software.version="1.3.1"
LABEL about.summary="HapCUT2: robust and accurate haplotype assembly for diverse sequencing technologies."
LABEL about.home="https://github.com/vibansal/HapCUT2"
LABEL about.documentation="https://github.com/vibansal/HapCUT2/blob/master/README.md"
LABEL license="https://github.com/vibansal/HapCUT2/blob/master/LICENSE"
LABEL about.tags="Genomics"

#################### MAINTAINER ######################

MAINTAINER Stephen Richer <sr467@bath.ac.uk>

#################### DOWNLOAD ########################

ENV HTSLIB_URL=https://github.com/samtools/htslib/releases/download/1.10.2/htslib-1.10.2.tar.bz2
ENV HAPCUT2_URL=https://github.com/vibansal/HapCUT2/archive/1ee1d58.tar.gz

WORKDIR /tmp

RUN apk update && \
    apk add --no-cache curl tar
RUN curl -L $HTSLIB_URL | tar -xj
RUN curl -L $HAPCUT2_URL | tar -xz

#################### BUILD ###########################

FROM alpine:3.9 AS build

COPY --from=download /tmp /tmp

RUN apk update && \
    apk add --no-cache \
      gcc \
      make \
      libc-dev \
      bzip2-dev \
      zlib-dev \
      libbz2 \
      xz-dev \
      libcurl
RUN cd /tmp/htslib* && \
    ./configure --prefix=/usr/local/ && \
    make && \
    make install
RUN cd /tmp/HapCUT2* && \
    make && \
    make install

#################### FINALISE ########################

FROM alpine:3.9

COPY --from=build /usr/local /usr/local

RUN apk update && apk add --no-cache \
      zlib \
      libbz2 \
      xz-dev \
      libcurl

USER guest

CMD ["HAPCUT2"]
