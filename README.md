# DevOps Task 
This tutorial walks you through all answers related to task 

> 1. Create an API service
i have create HTTP-API (e.g. RESTful) service that allows reading some data from moke data that have expose some metrics will find the describtions Iinstrument the code with a prometheus counter/gauge using prometheus
client libraries
* [restapi](api/restapi.md)



> Dockerize THE APP 
 Create a Dockerfile to build a docker image and automate the setup of your API
 service with Docker, so it can be run everywhere comfortably with one or two
 commands. 
 Bonus points:
 be sure to use best practices for creating Docker files: i.e. proper layer
structure, multi-stage builds if needed, security practices for building/running
containers.
* [docker](docker/docker.md)

> Create yaml manifest before creating the by creating the service and deployment and ingrees controal 
* [k8s](k8s/k8s.md)

> Create helm chart that content all yaml manifest template 
* [helm](helm/helm.md)

# Smoke test 
> will create ci/cd with gitlab ci/cd i have 
* install gitlab-runner 
* create gitlab-ci.yml 
* and do some change on src code thein push and see if it change or not 


> install gitlab-runner 
```
# curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
# yum install  gitlab-runner
```
> register gitlab-runner to the project 
```

# useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
# gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
# gitlab-runner register --url https://gitlab.com/ --registration-token sfsfsfs
```
``output``
```
[https://gitlab.com/]:
Enter the registration token:
[iCZKx9_67pizs8kiqvR4]:
Enter a description for the runner:
[gitlabtest]:
Enter tags for the runner (comma-separated):
restapi
Registering runner... succeeded                     runner=iCZKx9_6
Enter an executor: virtualbox, docker+machine, docker-ssh+machine, custom, docker-ssh, shell, ssh, docker, parallels, kubernetes:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```
now lets create simple gitlab-ci file 

```
#  cat << EOF |  tee .gitlab-ci.yml 
stages:
  - deploy 
Deploy.restapi: 
  stage: deploy
  only: 
    - master
  tags:
    - restapi
  before_script:
    - podman build -t restapi .
    - podman tag localhost/restapi:latest haydercyber/devops:$CI_PIPELINE_IID
    - podman push haydercyber/devops:$CI_PIPELINE_IID
  script:
    - helm upgrade --set deployment.image=haydercyber/devops:restapi  --set deployment.image=docker.io/haydercyber/devops:$CI_PIPELINE_IID demo helm
    - sleep 30s && cd 
  after_script:
    - curl -v restapi.helm.com/healthcheck
    - rm -rf /root/builds
EOF
```
when we push to master branch it will be run this script inside ``restapi`` runner 


* CI/CD VIEDO
<a href="https://drive.google.com/file/d/163ULWL1GpvD51WVxzLx7G1AiXb_1ZBYB/view?usp=sharing"><img src="https://drive.google.com/file/d/163ULWL1GpvD51WVxzLx7G1AiXb_1ZBYB/view?usp=sharing" style="width: 650px; max-width: 100%; height: auto" title="Click to enlarge picture" />
* you can check here simple ansible rules ``ansible dir `` that will configure cluster for k8s 
* install k8s in hard-way [k8s-hard-way](https://lnkd.in/d5ruPG4R) 

