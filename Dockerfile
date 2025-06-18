# OS
FROM ubuntu:latest AS builder
# Set version label
LABEL maintainer="github.com/dangdungcntt"
LABEL image="MTProxy"
LABEL OS="Ubuntu/latest"
ARG BUILD_COMMIT
ENV BUILD_COMMIT=${BUILD_COMMIT:-dc0c7f3de40530053189c572936ae4fd1567269b}
WORKDIR /srv/
ENV TZ=Asia/Singapore
# Update system packages:
RUN apt -y update > /dev/null 2>&1;\
# Fix for select tzdata region
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone > /dev/null 2>&1;\
    dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1;\
# Install dependencies, you would need common set of tools.
    apt -y install git curl unzip build-essential libssl-dev zlib1g-dev gcc-9 g++-9 cpp-9 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9 && \
# Clone the repo:
    curl -s -L https://github.com/TelegramMessenger/MTProxy/archive/$BUILD_COMMIT.zip -o /tmp/repo.zip && \
    unzip /tmp/repo.zip -d /tmp && \
    mv /tmp/MTProxy-$BUILD_COMMIT /srv/MTProxy && \
# Patch Makefile with specific commit
    sed -i 's/COMMIT := $(shell git log -1 --pretty=format:"%H")/COMMIT := dc0c7f3de40530053189c572936ae4fd1567269b/' /srv/MTProxy/Makefile && \
    rm /tmp/repo.zip && \
# To build, simply run make, the binary will be in objs/bin/mtproto-proxy:
    cd /srv/MTProxy && \
    make && \
# Clean up build dependencies and cache
    apt-get -y remove build-essential libssl-dev zlib1g-dev gcc-9 g++-9 cpp-9 && \
    apt-get -y autoremove && \
    apt-get clean

FROM ubuntu:latest AS runner
ENV TZ=Asia/Singapore
RUN apt -y update > /dev/null 2>&1;\
# Fix for select tzdata region
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone > /dev/null 2>&1;\
    dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
# Change WORKDIR
WORKDIR /srv/MTProxy/objs/bin/
# Copy built binary
COPY --from=builder /srv/MTProxy/objs/bin/mtproto-proxy /srv/MTProxy/objs/bin/mtproto-proxy
# Copy entrypoint script
COPY container-image-root/ /
RUN chmod +x /entrypoint.sh
# Expose Ports:
EXPOSE 8889/tcp 8889/udp
# ENTRYPOINT
ENTRYPOINT ["/entrypoint.sh"]
