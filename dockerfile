FROM node:latest
USER root
# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg -r --force-all doc-base
RUN mv /var/lib/dpkg/info/linux* ./
RUN dpkg --configure -a
RUN apt update &&  apt upgrade

# The node image comes with a base non-root 'node' user which this Dockerfile
# gives sudo access. However, for Linux, this user's GID/UID must match your local
# user UID/GID to avoid permission issues with bind mounts. Update USER_UID / USER_GID 
#ARG USER_UID=1000
#ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update && apt-get -y install --no-install-recommends apt-utils dialog apt-transport-https git iproute2 procps yarn 
RUN rm -rf /opt/yarn-* \
    && rm -f /usr/local/bin/yarn \
    && rm -f /usr/local/bin/yarnpkg \
    && apt-get install -y curl apt-transport-https lsb-release \
    && curl -sS https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ stable main" | tee /etc/apt/sources.list.d/yarn.list 
RUN npm install -g tslint typescript 
    #&& if [ "$USER_GID" != "1000" ]; then groupmod node --gid $USER_GID; fi \
    #&& if [ "$USER_UID" != "1000" ]; then usermod --uid $USER_UID node; fi \
    # [Optional] Add add sudo support for non-root user
    #&& apt-get install -y sudo \
    #&& echo node ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/node \
    #&& chmod 0440 /etc/sudoers.d/node \
    #
    # Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=
USER root
