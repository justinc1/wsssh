FROM huproxy:1 as builder

FROM nginx:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y openssh-server net-tools nano && apt clean
RUN echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config

COPY --from=builder /huproxy /
COPY --from=builder /huproxyclient /
COPY start_all.sh /
COPY wsssh.conf /etc/nginx/conf.d/default.conf
# COPY users.proxy /etc/nginx/
RUN echo "# empty htpasswd file" > /etc/nginx/users.proxy

CMD ["/start_all.sh"]
