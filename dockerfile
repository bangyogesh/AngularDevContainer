#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM node:8
USER root
# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg -r --force-all doc-base

# The node image comes with a base non-root 'node' user which this Dockerfile
# gives sudo access. However, for Linux, this user's GID/UID must match your local
# user UID/GID to avoid permission issues with bind mounts. Update USER_UID / USER_GID 
# if yours is not 1000. See https://aka.ms/vscode-remote/containers/non-root-user.
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update 

#The below steps are done as apt-utils list file is getting corrupt list
RUN apt-get -y download apt-utils

RUN dpkg -c /var/cache/apt/archives/apt-utils*.deb  | awk '{if ($6 == "./") { print "/."; } \
else if (substr($6, length($6), 1) == "/") \
{print substr($6, 2, length($6) - 2); } \
else { print substr($6, 2, length($6) - 1);}}' > /var/lib/dpkg/info/apt-utils.list

#
RUN apt-get -y install --no-install-recommends apt-utils 
RUN apt-get -y install --no-install-recommends dialog  
RUN apt-get install -y apt-transport-https
#
    # Verify git and needed tools are installed
RUN apt-get -y install git iproute2 procps     
    #
    # Remove outdated yarn from /opt and install via package 
    # so it can be easily updated via apt-get upgrade yarn
RUN rm -rf /opt/yarn-* \
    && rm -f /usr/local/bin/yarn \
    && rm -f /usr/local/bin/yarnpkg \
    && apt-get install -y curl apt-transport-https lsb-release \
    && curl -sS https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ stable main" | tee /etc/apt/sources.list.d/yarn.list 
   
RUN apt-get update 
RUN apt-get -y install --no-install-recommends yarn 
    #
    # Install tslint and typescript globally
RUN npm install -g tslint typescript 
    #
    # [Optional] Update a non-root user to match UID/GID - see https://aka.ms/vscode-remote/containers/non-root-user.
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
