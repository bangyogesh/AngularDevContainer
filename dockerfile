FROM node:lts

#Use the root user as needed to install the packages
USER root

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \ 
    #
    # Verify git and needed tools are installed
    && apt-get -y install git iproute2 procps \
    #
    # Remove outdated yarn from /opt and install via package 
    # so it can be easily updated via apt-get upgrade yarn
    && rm -rf /opt/yarn-* \
    && rm -f /usr/local/bin/yarn \
    && rm -f /usr/local/bin/yarnpkg \
    && apt-get install -y curl apt-transport-https lsb-release \
    && curl -sS https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/pubkey.gpg | apt-key add - 2>/dev/null \
    && echo "deb https://dl.yarnpkg.com/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get -y install --no-install-recommends yarn \
    #
    # Install tslint and typescript globally
    && npm install -g tslint typescript \
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
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    
# Any gitpod user specific settings shall go here
USER gitpod
RUN mkdir /home/gitpod/.npm-global \
    && ENV PATH=/home/node/.npm-global/bin:$PATH \
    && ENV NPM_CONFIG_PREFIX=/home/node/.npm-global \
    && npm install -g @angular/cli \


# Return to the root user
USER root
