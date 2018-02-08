FROM centos/ruby-23-centos7

USER root

RUN INSTALL_PKGS="cmake" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
    yum clean all -y

USER 1001
