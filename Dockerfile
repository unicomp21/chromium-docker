FROM ubuntu:16.04
MAINTAINER John Davis "jdavis@pcprogramming.com"
WORKDIR "/tmp"
RUN [ "apt-get", "update" ]
RUN [ "apt-get", "install", "-y", "git" ]
RUN [ "apt-get", "install", "-y", "python" ]
RUN [ "git", "clone", "https://chromium.googlesource.com/chromium/tools/depot_tools.git" ]
ENV PATH "$PATH:/tmp/depot_tools"
RUN [ "mkdir", "/tmp/chromium" ]
WORKDIR "/tmp/chromium"
RUN [ "fetch", "--nohooks", "chromium" ]

RUN apt-get install -y build-essential lsb-release sudo
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
RUN apt-get install -y ttf-mscorefonts-installer
RUN apt-get install -y zip xvfb xutils-dev xsltproc xcompmgr x11-utils
RUN apt-get install -y ttf-dejavu-core texinfo subversion ruby python-yaml python-psutil python-openssl
RUN apt-get install -y python-opencv python-numpy python-crypto python-cherrypy3 php7.0-cgi openbox mesa-common-dev

RUN apt-get install -y linux-libc-dev-armhf-cross libxtst-dev libxt-dev libxss-dev libxslt1-dev
RUN apt-get install -y libxkbcommon-dev libudev-dev libssl-dev libsqlite3-dev libspeechd2 libspeechd-dev
RUN apt-get install -y libsctp-dev libpulse0 libpulse-dev libpci3 libpci-dev libnss3-dev libnss3
RUN apt-get install -y libnspr4-dev libnspr4 libkrb5-dev libjpeg-dev libgtk2.0-dev libgtk-3-dev libgnome-keyring0
RUN apt-get install -y libgnome-keyring-dev libglu1-mesa-dev libglib2.0-dev libgles2-mesa-dev libgl1-mesa-dev
RUN apt-get install -y libgconf2-dev libgbm-dev libffi-dev libelf-dev libcurl4-gnutls-dev libcups2-dev libcap-dev
RUN apt-get install -y libcairo2-dev libc6-i386 libc6-dev-armhf-cross libbz2-dev libbrlapi0.6 libbrlapi-dev
RUN apt-get install -y libbluetooth-dev libav-tools libasound2-dev libasound2 libapache2-mod-php7.0 lib32stdc++6
RUN apt-get install -y lib32gcc1 gperf gcc-arm-linux-gnueabihf gcc-5-multilib-arm-linux-gnueabihf g++-arm-linux-gnueabihf
RUN apt-get install -y g++-5-multilib-arm-linux-gnueabihf fonts-thai-tlwg fonts-ipafont fonts-indic elfutils
RUN apt-get install -y curl cdbs binutils-aarch64-linux-gnu appmenu-gtk apache2-bin

RUN /tmp/chromium/src/build/install-build-deps.sh --no-chromeos-fonts --no-nacl --no-prompt
WORKDIR /tmp/chromium/src
RUN gclient runhooks
RUN gn gen out/Default

RUN ninja -C out/Default chrome

### ssh server
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
