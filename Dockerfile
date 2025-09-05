# Builder
FROM debian:trixie AS builder

# Dependencies
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

# Setup build
RUN git clone --depth 1 https://github.com/hercules-390/hyperion

WORKDIR /hyperion

COPY patches/ ./patches

RUN git apply ./patches/*.patch

RUN mkdir build

WORKDIR /hyperion/build

RUN cmake ..

# Build
RUN cmake --build .

# Runner
FROM debian:trixie AS runner

# Dependencies
RUN DEBIAN_FRONTEND=noninteractive apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y cmake

# Setup
COPY --from=builder /hyperion /hyperion

WORKDIR /hyperion/build

# Install
RUN cmake -P cmake_install.cmake

# Create a working directory
WORKDIR /

RUN rm -rf /hyperion

RUN mkdir hercules

WORKDIR /hercules

ENTRYPOINT ["hercules"]