FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

# Install build dependencies for TDLib
RUN apt-get update && apt-get install -y \
    make \
    git \
    cmake \
    g++ \
    libssl-dev \
    zlib1g-dev \
    gperf \
    php-cli \
    ca-certificates \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24
RUN wget -q https://go.dev/dl/go1.24.4.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz && \
    rm go1.24.4.linux-amd64.tar.gz

ENV PATH=/usr/local/go/bin:$PATH
ENV GOPATH=/go

# Build and install TDLib
WORKDIR /build/td
COPY . .
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    cmake --build . -j$(nproc) && \
    cmake --build . --target install -j$(nproc)

# Clean up build artifacts to reduce image size
RUN rm -rf /build/td/build/*.o /build/td/build/CMakeFiles

WORKDIR /workspace

# Verify TDLib installation
RUN ldconfig && \
    ls -la /usr/local/lib/libtdjson* && \
    ls -la /usr/local/include/td/

# Default command
CMD ["/bin/bash"]
