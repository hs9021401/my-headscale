FROM headscale/headscale:latest
RUN apk add --no-cache bash coreutils
COPY ./config /etc/headscale
EXPOSE 8080
ENTRYPOINT ["headscale"]
CMD ["sh", "-c", "headscale serve & sleep infinity"]