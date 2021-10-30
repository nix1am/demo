FROM centos

LABEL maintainer="nix1am@nix1am.ru"

ENV container=docker  
 
COPY container.target /etc/systemd/system/container.target
 
RUN ln -sf /etc/systemd/system/container.target /etc/systemd/system/default.target
 
ENTRYPOINT ["/sbin/init"]

RUN yum install cockpit -y

STOPSIGNAL SIGRTMIN+3

CMD ["--log-level=info"]

EXPOSE 9090

VOLUME cockpit