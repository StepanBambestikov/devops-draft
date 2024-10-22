FROM golang:1.19-alpine AS builder
WORKDIR /app
COPY main.go .
ENV GO111MODULE auto
RUN  go mod init main && \
     go mod tidy && \
     go build -o app
FROM golang:1.19-alpine
WORKDIR /app
COPY --from=builder /app/app .
RUN ls app
RUN pwd
CMD ["/app/app"]
