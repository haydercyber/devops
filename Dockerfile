FROM golang:1.16.12-alpine3.15 as builder
RUN mkdir /app 
WORKDIR /app 
COPY go.mod .
COPY  go.sum  .
COPY restapi.go . 
RUN GOGC=off CGO_ENABLED=0 go build -v -o restapi 
# Create the user and group files that will be used in the running container to
# run the process as an unprivileged user.
RUN mkdir /user && \
    echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd && \
    echo 'nobody:x:65534:' > /user/group
# create final image
FROM scratch
EXPOSE 9098
WORKDIR / 
USER nobody:nobody
COPY --from=builder /user/group /user/passwd /etc/
COPY --from=builder /app/restapi/  /restapi
CMD ["/restapi"]
