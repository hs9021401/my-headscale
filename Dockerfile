FROM headscale/headscale:latest
COPY ./config /etc/headscale
EXPOSE 8080
ENTRYPOINT ["headscale"]
CMD ["sh", "-c", "headscale serve & sleep infinity"]