FROM ubuntu:20.04
EXPOSE 8080
COPY ./haskell-url-shortener/haskell-url-shortener-exe /url-shortener
CMD ["/url-shortener"]
