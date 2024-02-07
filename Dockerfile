FROM huproxy:1 as builder

FROM nginx:latest
COPY --from=builder /huproxy /
COPY --from=builder /huproxyclient /
COPY wsssh.conf /etc/nginx/conf.d/default.conf
COPY users.proxy /etc/nginx/
CMD ["sh", "-c", "/huproxy -listen 127.0.0.1:8086 & nginx -g 'daemon off;'"]
