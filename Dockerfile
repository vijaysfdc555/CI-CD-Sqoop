FROM ubuntu:18.04
LABEL MAINTAINER="vijay"
WORKDIR /usr/local
ADD http://archive.apache.org/dist/sqoop/1.4.5/sqoop-1.4.5.tar.gz .
RUN tar xvzf sqoop-1.4.5.tar.gz
RUN mv sqoop-1.4.5 sqoop
RUN chown -R hduser:hadoop /usr/local/sqoop
ENV SQOOP_HOME=/usr/local/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin
WORKDIR /usr/local/sqoop/conf
COPY sqoop-env.sh /usr/local/sqoop/conf/sqoop-env.sh
ADD https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.30/mysql-connector-java-5.1.30.jar .
RUN mysql-connector-java-5.1.30.jar  /usr/local/sqoop/lib/
EXPOSE 50075 50070 50060 50030 54310 54311
EXPOSE 8030 8031 8032 8033 8040 8042 8088
EXPOSE 19888
WORKDIR /usr/local/sqoop/bin
