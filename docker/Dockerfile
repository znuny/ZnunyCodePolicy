FROM perl:5.34-bullseye

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        libexpat1-dev \
        libssl-dev \
        libxml2-dev \
        libxml2-utils \
        libxslt1-dev \
        make \
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

# Mounted workdirs often trigger Git "dubious ownership" when running as host uid.
RUN git config --system --add safe.directory /workspace

RUN cpanm --notest \
        Algorithm::Diff \
        Code::TidyAll \
        Perl::Critic \
        Perl::Tidy \
        Pod::POM \
        XML::Parser \
        Text::PO::Gettext

WORKDIR /opt/znuny-codepolicy
COPY . /opt/znuny-codepolicy

RUN perl /opt/znuny-codepolicy/bin/znuny.CodePolicy.pl --install-eslint

ENTRYPOINT ["perl", "/opt/znuny-codepolicy/bin/znuny.CodePolicy.pl"]
CMD ["--all-files"]
