FROM --platform=amd64 ubuntu:jammy AS base

RUN apt update -qq && apt upgrade -y && apt install --no-install-recommends -y lsb-release gnupg software-properties-common dirmngr wget curl
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
 add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

RUN ln -fs /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt update -qq && apt install -y r-base automake libtool m4 automake build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev libbz2-dev liblzma-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev


FROM base AS base-app

WORKDIR /
RUN mkdir /app
RUN mkdir /build_deps
COPY ./R/installPackages.R /build_deps
WORKDIR /build_deps
RUN Rscript installPackages.R

FROM base-app AS app
COPY . /app
WORKDIR /app/R
RUN ls
ENTRYPOINT [ "Rscript", "runAll.R" ]