FROM golang:1.16
RUN apt update && apt upgrade -y $$ apt install gzip -y
