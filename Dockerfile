FROM golang:1.16
RUN apt update && apt upgrade $$ apt install gzip -y
