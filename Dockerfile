FROM centos:7
RUN yum install epel-release -y && yum clean all
RUN yum update -y && yum clean all
RUN yum install git vim net-tools telnet -y
RUN yum install wget -y
RUN git clone https://github.com/cuongvomanh/kafka_sasl_ssl.git
RUN cd kafka_sasl_ssl && bash init.sh
RUN yum install java-1.8.0-openjdk -y
RUN yum install syslinux -y
#RUN cd kafka_sasl_ssl && ./scritps/run.sh

