#  Dockerize the app with multe stage of container 
i use go becuses is Build fast, reliable, and efficient software at scale
Go is an open source programming language supported by Google
Easy to learn and get started with
Built-in concurrency and a robust standard library
Growing ecosystem of partners, communities, and tools Go was designed at Google in 2007 to improve programming productivity in an era of multicore, networked machines and large codebases.The designers wanted to address criticism of other languages in use at Google, but keep their useful characteristics:
static typing and run-time efficiency (like C),
readability and usability (like Python or JavaScript)
high-performance networking and multiprocessing.
The designers were primarily motivated by their shared dislike of C++.
Go was publicly announced in November  and version 1.0 was released in March 2012 Go is widely used in production at Google and in many other organizations and open-source projects

lets preper the test enviroment we should install podman 

# Tasks will do 
- download podman  
- clone the repo 
- dockerize the app with one stage 
- dockerize the app with with multi stage 
- tag the image thien push to dockerhub 

> podman will install podman Podman is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode. this resion why i use podman rootless 

```
# yum install podman -y 
```

> clone the repo 

```
# git clone https://github.com/haydercyber/devops.git
# cd devops
```
> let create dockerfile that to containes all application dependency
 
```
# cat <<EOF>> Dockerfile  
FROM golang:1.16.12-alpine3.15 
WORKDIR /app
COPY go.mod .
COPY  go.sum  .
COPY restapi.go .
RUN GOGC=off CGO_ENABLED=0 go build -v -o restapi
CMD [ "./restapi"]
EOF
```
``Explain The Steps``


``FROM`` creates a layer from the ``golang:1.16.12-alpine3.15``  Docker image.

``WORKDIR``  instruction sets the working directory for any ``COPY`` ``RUN`` ``CMD`` If the  ``WORKDIR``  doesn’t exist, it will be created even if it’s not used in any subsequent

``COPY`` instruction copies new files or directories from ``<src>`` and adds them to the filesystem of the container at the path ``<dest>`` in my case i add some file related to build such as ``go.mod`` ``go.sum`` ``restapi.go`` to ``WORKDIR`` is ``/app`` 

``RUN`` run command to build the project to convert the src code to binary 

``CMD`` The main purpose of a to executing  ``./restapi`` the app binray 

`` build the image `` now will have some issue related to size and security 
```
# docker build -t restapi .
```
``Explain The Steps``

The  `` docker build``  command builds Docker images from a Dockerfile and a “context”. A build’s context is the set of files located in the specified ``PATH`` or ``URL``  The build process can refer to any of the files in the context. For example, your build can use a ``COPY`` ``RUN`` and `` -t `` Name and optionally a tag in the ``restapi:latest`` format,  in  example specifies that the ``Dockerfile`` in currnet Directory 

`` output of build `` 
```
STEP 1/7: FROM golang:1.16.12-alpine3.15
STEP 2/7: WORKDIR /app
--> 95ece2f8836
STEP 3/7: COPY go.mod .
--> b4f0c475d79
STEP 4/7: COPY  go.sum  .
--> 87db7158a96
STEP 5/7: COPY restapi.go .
--> f4500237b98
STEP 6/7: RUN GOGC=off CGO_ENABLED=0 go build -v -o restapi
go: downloading github.com/gorilla/mux v1.8.0
go: downloading github.com/prometheus/client_golang v1.12.1
go: downloading github.com/prometheus/client_model v0.2.0
go: downloading github.com/prometheus/common v0.32.1
go: downloading github.com/beorn7/perks v1.0.1
go: downloading github.com/cespare/xxhash/v2 v2.1.2
go: downloading github.com/golang/protobuf v1.5.2
go: downloading github.com/prometheus/procfs v0.7.3
go: downloading google.golang.org/protobuf v1.26.0
go: downloading github.com/matttproud/golang_protobuf_extensions v1.0.1
go: downloading golang.org/x/sys v0.0.0-20220114195835-da31bd327af9
google.golang.org/protobuf/internal/flags
google.golang.org/protobuf/internal/set
golang.org/x/sys/internal/unsafeheader
github.com/beorn7/perks/quantile
github.com/cespare/xxhash/v2
google.golang.org/protobuf/internal/pragma
net
google.golang.org/protobuf/internal/detrand
google.golang.org/protobuf/internal/version
github.com/prometheus/common/internal/bitbucket.org/ww/goautoneg
github.com/prometheus/common/model
google.golang.org/protobuf/internal/errors
github.com/prometheus/procfs/internal/fs
github.com/prometheus/procfs/internal/util
google.golang.org/protobuf/encoding/protowire
golang.org/x/sys/unix
google.golang.org/protobuf/reflect/protoreflect
google.golang.org/protobuf/internal/encoding/messageset
google.golang.org/protobuf/internal/strs
google.golang.org/protobuf/internal/genid
google.golang.org/protobuf/internal/encoding/text
crypto/x509
net/textproto
vendor/golang.org/x/net/http/httpproxy
google.golang.org/protobuf/internal/order
google.golang.org/protobuf/reflect/protoregistry
vendor/golang.org/x/net/http/httpguts
mime/multipart
google.golang.org/protobuf/runtime/protoiface
crypto/tls
google.golang.org/protobuf/internal/encoding/defval
google.golang.org/protobuf/proto
google.golang.org/protobuf/internal/descfmt
google.golang.org/protobuf/internal/descopts
github.com/prometheus/procfs
google.golang.org/protobuf/encoding/prototext
google.golang.org/protobuf/internal/filedesc
net/http/httptrace
net/http
google.golang.org/protobuf/internal/encoding/tag
google.golang.org/protobuf/internal/impl
google.golang.org/protobuf/internal/filetype
google.golang.org/protobuf/runtime/protoimpl
google.golang.org/protobuf/types/known/timestamppb
google.golang.org/protobuf/types/known/anypb
google.golang.org/protobuf/types/descriptorpb
github.com/golang/protobuf/ptypes/timestamp
github.com/golang/protobuf/ptypes/any
google.golang.org/protobuf/types/known/durationpb
github.com/golang/protobuf/ptypes/duration
google.golang.org/protobuf/reflect/protodesc
expvar
github.com/gorilla/mux
github.com/golang/protobuf/proto
github.com/prometheus/client_model/go
github.com/matttproud/golang_protobuf_extensions/pbutil
github.com/golang/protobuf/ptypes
github.com/prometheus/client_golang/prometheus/internal
github.com/prometheus/common/expfmt
github.com/prometheus/client_golang/prometheus
github.com/prometheus/client_golang/prometheus/promhttp
restapi.go
--> f7d8afe6921
STEP 7/7: CMD [ "./restapi"]
COMMIT restapi
--> 7b7fd851a73
Successfully tagged localhost/restapi:latest
```
``lets check if all func is working or not `` 

```
# curl  -v localhost:9098/healthcheck
```
``output``
```
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 9098 (#0)
> GET /healthcheck HTTP/1.1
> Host: localhost:9098
> User-Agent: curl/7.61.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Sat, 19 Mar 2022 14:52:49 GMT
< Content-Length: 2
< Content-Type: text/plain; charset=utf-8
<
* Connection #0 to host localhost left intact
```
`` all func is work that is Great `` BUT we have some issues ``let discussion what the issues and how to fix it ``

`` lets check the first issues with this image `` is the size for image you can see it vi 
```
# podman image ls |  grep "localhost/restapi"
```
`` Explain The command ``  it list all image 

``output of command ``

```
localhost/restapi             latest              7b7fd851a730  23 minutes ago     389 MB
```
the size of image is ``389MB`` is big issues and you have issues the src code stile inside container if any attacker can access the container can see the ``src code ``  because `` the container run as root `` let see the output of ``user`` and `` src `` 

```
# podman exec -it restapi ls /app 
```
`` Explain The command ``  command runs a new command in a running container i have list the all content of ``WORKDIR`` 

``output of command ``

```
go.mod      go.sum      restapi     restapi.go 
```
all of ``src code `` its inside the container and this is security issues and the can pick the src code outside of container becuse the user is ``root`` we can check by run this command

```
# podman exec -it restapi id
```
``output`` 
```
uid=0(root) gid=0(root) 
```
> let rebuild the image with mult-stage One of the most challenging things about building images is keeping the image size down. Each instruction in the Dockerfile adds a layer to the image, and you need to remember to clean up any artifacts you don’t need before moving on to the next layer. To write a really efficient Dockerfile, you have traditionally needed to employ shell tricks and other logic to keep the layers as small as possible and to ensure that each layer has the artifacts it needs from the previous layer and nothing else.

```
#  cat <<EOF>> Dockerfile  
FROM golang:1.16.12-alpine3.15 AS builder
WORKDIR /app
COPY go.mod .
COPY  go.sum  .
COPY restapi.go .
RUN GOGC=off CGO_ENABLED=0 go build -v -o restapi
CMD [ "./restapi"]
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
EOF
```
``Explain The Steps`` 

``FROM`` creates a layer from the ``golang:1.16.12-alpine3.15``  Docker image AS build step 

``RUN`` run command Create the user and group files that will be used in the running container to run the process as an unprivileged user.

``FROM`` creates a new layer from ``scratch`` This image is most useful in the context of building base images  or super minimal images (that contain only a single binary for `` go app ``

``EXPOSE``   instruction informs Docker that the container listens on the specified network ports at runtime. You can specify whether the port listens on TCP or UDP, and the default is TCP if the protocol is not specified the ``EXPOSE``  instruction does not actually publish the port. It functions as a type of documentation between the person who builds the image and the person who runs the container, about which ports are intended to be published 


``USER``  instruction sets the user name (or UID) and optionally the user group (or GID) to use when running the image and for any any my case i use user and group ``nobody:nobody`` 

``COPY`` with flag ``--from`` ine copies just the built artifact from the previous stage into this new stage we just copy the user and group and bainry 

``CMD`` The main purpose of a to executing  ``./restapi`` the app binray  

``lets build the image and see how we fix the three issues abouve ``

```
#  podman build -t restapi .
```
``output``
```
[1/2] STEP 1/8: FROM golang:1.16.12-alpine3.15 AS builder
[1/2] STEP 2/8: WORKDIR /app
--> Using cache 95ece2f8836ec248a9e5bfd10e74cb554fa04f497dff33608b205cc1e98d9e65
--> 95ece2f8836
[1/2] STEP 3/8: COPY go.mod .
--> Using cache b4f0c475d792e2e932ae3f0c81c0e8877cf2fcdaf0edffc65f39912b1c994458
--> b4f0c475d79
[1/2] STEP 4/8: COPY  go.sum  .
--> Using cache 87db7158a964d8fc894c1413e1d8352e435fbcaf76c764e7b56c9e07b297bb39
--> 87db7158a96
[1/2] STEP 5/8: COPY restapi.go .
--> Using cache f4500237b98ee72fe1a46745e780adfdcf742c148e9fb917f73f733b1b86ceaf
--> f4500237b98
[1/2] STEP 6/8: RUN GOGC=off CGO_ENABLED=0 go build -v -o restapi
--> Using cache f7d8afe692183153966d5105d36113f0c0ec1556d96cad90357f6057f62e34ab
--> f7d8afe6921
[1/2] STEP 7/8: CMD [ "./restapi"]
--> Using cache 7b7fd851a7305125c0c4db0617ff7ba17ad33e5290a2cf034c4736a5c3fbf69d
--> 7b7fd851a73
[1/2] STEP 8/8: RUN mkdir /user &&     echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd &&     echo 'nobody:x:65534:' > /user/group
--> 48f7e49273a
[2/2] STEP 1/7: FROM scratch
[2/2] STEP 2/7: EXPOSE 9098
--> Using cache 316af5c62bc7dd7414962d7b2bfa1be1852da817906b53df416ea4c86016daa9
--> 316af5c62bc
[2/2] STEP 3/7: WORKDIR /
--> Using cache 9e7867496e76177577e670f78f498957d01b8b676915bd0da3a39c9710928a45
--> 9e7867496e7
[2/2] STEP 4/7: USER nobody:nobody
--> Using cache d96f5251eb4c6b643f9caae1b03f6b71c7d7ff0f961411449a248c252fbf5422
--> d96f5251eb4
[2/2] STEP 5/7: COPY --from=builder /user/group /user/passwd /etc/
--> Using cache 02a39dd30263d2126d6c3af42de0d68ef3f301aa21ebe2c322981212894f0642
--> 02a39dd3026
[2/2] STEP 6/7: COPY --from=builder /app/restapi/  /restapi
--> Using cache 35184bf51ce44815309e65ab7cf09a99f991fea336a0d3f32d1d4e0284567b68
--> 35184bf51ce
[2/2] STEP 7/7: CMD ["/restapi"]
--> Using cache dac15cc30abecd6ef512b6202e463cae685a1af0e75ba5ff918aab405df54770
[2/2] COMMIT restapi
--> dac15cc30ab
Successfully tagged localhost/restapi:latest
```
> first will check the size 
```
podman image ls |  grep "localhost/restapi" 
```
``output ``
```
localhost/restapi             latest              dac15cc30abe  10 hours ago        11.6 MB
```
the size now is ``11.6 MB`` its lower thin ``389 MB`` it buter when working with remote repo its givein speed of delivery 

> second issues is the src code and root privalge lets check if it still or not 

```
# podman exec -it restapi ls
# podman exec -it restapi id
```
`` output of command `` 
```
tarting container process caused: exec: "ls": executable file not found in $PATH: OCI runtime attempted to invoke a command that was not found
starting container process caused: exec: "id": executable file not found in $PATH: OCI runtime attempted to invoke a command that was not found

```
that means  is no command found 

> lets check the func of code 

```
# curl  -v localhost:9098/healthcheck
```
``output``
```
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 9098 (#0)
> GET /healthcheck HTTP/1.1
> Host: localhost:9098
> User-Agent: curl/7.61.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Sat, 19 Mar 2022 15:31:25 GMT
< Content-Length: 2
< Content-Type: text/plain; charset=utf-8
<
* Connection #0 to host localhost left intact
```
> the last task we should tag the image thein push it docker hub 

`` just we need to  create repo `` 
then tag the image and push 
```
# podman push docker.io/haydercyber/devops:restapi
```

``output``
```
Getting image source signatures
Copying blob 8132e5068cf5 done
Copying blob 526b478e02aa done
Copying config dac15cc30a done
Writing manifest to image destination
Storing signatures
```
now the image ready to use in k8s  

Next: [create k8s minfits manifest ](../k8s/k8s.md)
