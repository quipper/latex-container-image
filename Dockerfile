FROM ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get -y install --no-install-recommends --no-install-suggests \
      git \
      fontconfig \
      ghostscript \
      xz-utils \
      locales \
      wget \
      curl \
      ca-certificates \
      gpg \
      unzip \
      poppler-utils \
      libatomic1 && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# We want to use UTF-8, mostly for displaying file paths.
# (C.UTF-8 doesn't seem to work properly, `ls` by default still escapes UTF-8 file names)
ENV LANG="en_US.UTF-8"

# Install TeX Live itself.
# Ref: https://tug.org/texlive/quickinstall.html
COPY custom-texlive.profile /custom-texlive.profile
RUN mkdir texlive-installer && \
    cd texlive-installer && \
    wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar xzf install-tl-unx.tar.gz && \
    cd install-tl-20* && \
    mv /custom-texlive.profile . && \
    perl ./install-tl --profile=custom-texlive.profile && \
    ln -s /usr/local/texlive/20?? /usr/local/texlive/current && \
    ln -s /usr/local/texlive/20??/bin/*-linux/ /usr/local/texlive/current/bin/current && \
    cd ../.. && \
    rm -rf texlive-installer

ENV PATH="/usr/local/texlive/current/bin/current:$PATH"

# Build font caches.
# Ref: https://github.com/xu-cheng/latex-docker
# Ref: https://www.tug.org/texlive/doc/texlive-en/texlive-en.html#x1-320003.4.4
RUN ln -s $(readlink -e /usr/local/texlive/current/texmf-var/fonts/conf/texlive-fontconfig.conf) /etc/fonts/conf.d/09-texlive.conf && \
    fc-cache -f && \
    luaotfload-tool -fu

# Install AWS CLI
# Ref: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
RUN mkdir aws-cli-installer && \
    cd aws-cli-installer && \
    curl -sf "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o awscliv2.zip && \
    unzip -q awscliv2.zip && \
    ./aws/install --update && \
    aws --version && \
    cd .. && \
    rm -rf aws-cli-installer
