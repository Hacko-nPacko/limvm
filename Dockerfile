FROM ubuntu:14.04.4
MAINTAINER atanas@less-is-more.dk

ENV DEBIAN_FRONTEND noninteractive

# install the required software
RUN apt-get install -y software-properties-common curl git subversion

# Enable Ubuntu repositories
RUN add-apt-repository -y multiverse && \
  add-apt-repository -y restricted && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && apt-get dist-upgrade -y

# Install latest Oracle Java from PPA
RUN echo oracle-java8-installer \
  shared/accepted-oracle-license-v1-1 select true \
  | /usr/bin/debconf-set-selections && \
  apt-get install -y oracle-java8-installer oracle-java8-set-default supervisor openssh-server

RUN mkdir -p /var/run/sshd /var/log/supervisor

ADD sshd.conf /etc/supervisor/conf.d/sshd.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD id_rsa.pub /root/.ssh/authorized_keys

VOLUME ["/vms/shared", "/vms/private"]

RUN echo "root:root" | chpasswd


ENV CATALINA_HOME /server/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.32
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
	&& wget "$TOMCAT_TGZ_URL" -O tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm tomcat.tar.gz

ENV MAVEN_HOME /opt/maven3
RUN mkdir -p "$MAVEN_HOME"
WORKDIR $MAVEN_HOME

ENV MAVEN_MAJOR 3
ENV MAVEN_VERSION 3.3.9
ENV MAVEN_TGZ_URL http://apache.cbox.biz/maven/maven-$MAVEN_MAJOR/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

RUN set -x \
	&& wget "$MAVEN_TGZ_URL" -O maven.tar.gz \
	&& tar -xvf maven.tar.gz --strip-components=1 \
	&& pwd && ls -la \
	&& rm maven.tar.gz

RUN ln -s $MAVEN_HOME/bin/mvn /usr/bin/
RUN locale-gen en_US en_US.UTF-8

EXPOSE 80
EXPOSE 8080

CMD /usr/bin/supervisord -n
