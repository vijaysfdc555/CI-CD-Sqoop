FROM ubuntu:18.04
LABEL MAINTAINER="vijay"
RUN apt update && apt install  openssh-server sudo -y
# Create a user “sshuser” and group “sshgroup”
RUN addgroup hadoop
RUN useradd -ms /bin/bash -g hadoop hduser
RUN adduser hduser sudo
# Create sshuser directory in home
RUN mkdir -p /home/hduser/.ssh
# Copy the ssh public key in the authorized_keys file. The idkey.pub below is a public key file you get from ssh-keygen. They are under ~/.ssh directory by default.
COPY id_rsa /home/hduser/.ssh/id_rsa
COPY id_rsa.pub /home/hduser/.ssh/id_rsa.pub
COPY id_rsa.pub /home/hduser/.ssh/authorized_keys
# change ownership of the key file.
RUN chown hduser:hadoop /home/hduser/.ssh/id_rsa && chmod 600 /home/hduser/.ssh/id_rsa
RUN chown hduser:hadoop /home/hduser/.ssh/id_rsa.pub && chmod 600 /home/hduser/.ssh/id_rsa.pub
RUN chown hduser:hadoop /home/hduser/.ssh/authorized_keys && chmod 600 /home/hduser/.ssh/authorized_keys
# java installation
RUN  mkdir -p /usr/local/hadoop
WORKDIR /usr/local
RUN apt-get install openjdk-8-jdk -y
RUN su hduser
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
# Start SSH service
RUN service ssh start
# Expose docker port 22
EXPOSE 22

WORKDIR /usr/local
ADD https://archive.apache.org/dist/hadoop/core/hadoop-1.2.1/hadoop-1.2.1.tar.gz .
RUN tar -xvf hadoop-1.2.1.tar.gz
RUN mv hadoop-1.2.1/* hadoop
RUN chown -R hduser:hadoop hadoop
RUN chown -R hduser:hadoop /home/hduser/.ssh
RUN JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN PATH=$PATH:$JAVA_HOME/bin
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_INSTALL=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

COPY core-site.xml /usr/local/hadoop/conf/core-site.xml
COPY mapred-site.xml /usr/local/hadoop/conf/mapred-site.xml
COPY hdfs-site.xml /usr/local/hadoop/conf/hdfs-site.xml
COPY hadoop-env.sh /usr/local/hadoop/conf/hadoop-env.sh
COPY masters /usr/local/hadoop/conf/masters
COPY slaves /usr/local/hadoop/conf/slaves
RUN mkdir -p /app/hadoop/tmp
RUN chown -R hduser:hadoop /app/hadoop/tmp
EXPOSE 50075 50070 50060 50030 54310 54311
WORKDIR /usr/local/hadoop/bin
RUN chmod 750 /app/hadoop/tmp

#Sqoop
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
RUN cp mysql-connector-java-5.1.30.jar  /usr/local/sqoop/lib/
EXPOSE 8030 8031 8032 8033 8040 8042 8088
EXPOSE 19888
WORKDIR /usr/local/sqoop/bin

CMD ["/usr/sbin/sshd","-D"]
