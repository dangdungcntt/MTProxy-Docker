# OS
FROM ubuntu:latest
# Set version label
LABEL maintainer="github.com/dangdungcntt"
LABEL image="MTProxy"
LABEL OS="Ubuntu/latest"
ARG WORKERS
ENV WORKERS=${WORKERS:-1}
ARG MTPROTO_REPO_URL
ENV MTPROTO_REPO_URL=${MTPROTO_REPO_URL:-https://github.com/TelegramMessenger/MTProxy}
WORKDIR /srv/
ENV TZ=Asia/Singapore
# Update system packages:
RUN apt -y update > /dev/null 2>&1;\
# Fix for select tzdata region
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone > /dev/null 2>&1;\
    dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1;\
# Install dependencies, you would need common set of tools.
    apt -y install git curl build-essential libssl-dev zlib1g-dev cron wget logrotate ntp > /dev/null 2>&1;\
    apt install -y gcc-9 g++-9 cpp-9 > /dev/null 2>&1;\
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9 > /dev/null 2>&1;\
# Clone the repo:
    git clone ${MTPROTO_REPO_URL} /srv/MTProxy > /dev/null 2>&1 ;\
# To build, simply run make, the binary will be in objs/bin/mtproto-proxy:
    cd /srv/MTProxy ; \
    make > /dev/null 2>&1;\
# Obtain current telegram configuration. It can change (occasionally), so we encourage you to update it once per day.
    (crontab -l 2>/dev/null; echo '0 4 * * *  pkill -f mtproto-proxy  >> /var/log/cron.log 2>&1') | crontab - ;\
# Cleanup
    apt-get clean > /dev/null 2>&1;\
    # Info message for the build
    echo -e "\e[1;31m \n\
    ███╗   ███╗████████╗██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗ \n\
    ████╗ ████║╚══██╔══╝██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝ \n\
    ██╔████╔██║   ██║   ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝ \n\
    ██║╚██╔╝██║   ██║   ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝  \n\
    ██║ ╚═╝ ██║   ██║   ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║   \n\
    ╚═╝     ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝ \e[0m \n\
    All is setup and done! \n\
    For access MTProxy use this link: \n\
    \e[1;33mtg://proxy?server=<ip>&port=<port>&secret=<secret>\e[0m"
# Change WORKDIR
WORKDIR /srv/MTProxy/objs/bin/
COPY container-image-root/ /
# Expose Ports:
EXPOSE 8889/tcp 8889/udp
# ENTRYPOINT
ENTRYPOINT "/entrypoint.sh"
