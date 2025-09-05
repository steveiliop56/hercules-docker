FROM debian:trixie AS builder

RUN DEBIAN_FRONTEND=noninteractive apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential \
    cmake \
    git \
    sed \
    autoconf \
    automake \
    flex \
    gawk \
    grep \
    m4 \
    perl

RUN git clone --depth 1 https://github.com/hercules-390/hyperion

WORKDIR /hyperion

COPY patches/ ./patches

RUN git apply ./patches/*.patch

RUN mkdir build

WORKDIR /hyperion/build

RUN cmake ..

RUN cmake --build .

FROM debian:trixie AS runner

RUN DEBIAN_FRONTEND=noninteractive apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y cmake

COPY --from=builder /hyperion /hyperion

WORKDIR /hyperion/build

RUN cmake -P cmake_install.cmake

WORKDIR /

RUN rm -rf /hyperion

RUN mkdir hercules

WORKDIR /hercules

ENTRYPOINT ["hercules"]