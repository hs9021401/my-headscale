FROM headscale/headscale:latest
COPY ./config /etc/headscale
EXPOSE 8080
CMD ["serve"]