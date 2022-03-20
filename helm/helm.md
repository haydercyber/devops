# Helm install and templating the app 
Helm is a package manager for Kubernetes.

What Is a Package Manager? 
Managed
Single command installation
Dependencies are resolved
Does not require deep understanding of software
Easier updates, upgrades, and removal

Unmanaged
Dependencies must be satisfied manually
Each part of the application must be installed, updated, upgraded, or removed separately
Requires in-depth knowledge of the application architecture

How Packages Are Installed 
Read Metadata Installation Packaged applications have accompanying data that indicates how it is installed (e.g., dependencies).
Resolve Dependencies Configuration  Not only do we know what the application stack depends on, we also know where to get it and how to install it.
Installation The pieces of the package are installed in order. This prevents failures by ensuring that requirements are met
Configuration The installed components of a package may require post installation steps (e.g., linking databases). 
Why Package Management Is Better 
Old Manual Way Someone with knowledge of the application would need to create an installation plan, create a dependency plan, and install and configure the application. 
Package Management Everything is in the package. Installation is typically one command. Once installed, the application is ready to use.
How Helm Manages Packages
Helm Chart This is the definition of a Kubernetes application. Helm uses this information along with a config to instantiate a released object.
Least Invasive Change In the event that there is a change to a release, Helm will only change what has been updated since last release.  
Running vs Desired State If a Helm chart has been released, Helm can determine what the current state of the environment is vs the desired state and make changes as needed.
Release Tracking Helm versions. This means that if something goes wrong, the release can be rolled back to a previous version.

What Helm Can Do for You 
Single Command Install With the helm install command, a chart can be released using a Helm repository. 
Provide Insights for Releases With the helm status command, it is possible to see the details of the running state of a release.
Perform Simple Updates/Upgrades With the helm upgrade command, you can apply changes to a chart (e.g., versioning a service) and helm will do the update for you.
Provide the Ability to Rollback Helm tracks releases and versions them. By using the helm rollback command, it is possible to revert to a previous release.
Simplify Deployment Charts can be created by the application expert and released by someone else with a single command.
Single Command Uninstall By using helm uninstall, the reverse of the installation can be done. This makes a cleaner removal, as all components that are defined are also removed.

Deploying to Kubernetes without Helm
Deployment Steps
Scope the Deployment 
Determine what we need to create. Do we need persistent volumes? Do we need services for the database
Create Dependencies 
Create dependencies according to what we have determined is needed in the environment, such as persistent volumes

Create Manifests 
We will need to create manifests for each of the objects that we want to deploy (e.g., if we need a database, we need to handle the login info).
Deploy Manifests 
The manifests that we have created need to be deployed in the correct order. We need to ensure that the deployment is successful before moving to the next item.
Perform Configuration 
Any application-specific configuration that needs to be done (e.g., logging in to the application) can now be done.

Deploying to Kubernetes Using Helm
Deployment Steps
Locate a Chart 
For the majority of applications you may want to deploy, there is an existing chart. These charts are located in a repository and can be deployed using some custom configurations.
Deploy the Chart
For the majority of applications you may want to deploy, there is an existing chart. These charts are located in a repository and can be deployed using some custom configurations.
Perform Configuration
For the majority of applications you may want to deploy, there is an existing chart. These charts are located in a repository and can be deployed using some custom configurations.

Installing Helm

Before We Begin You will need to have a Kubernetes cluster installed and configured so that kubectl is working correctly. If you plan to install a chart that uses persistent storage, you need to have your storage classes configured correctly so the PVCs can be created.

Installation Methods 
Package Manager The Helm community has made packages available for Homebrew, Chocolatey, and APT, as well as a Snap package.
Provided Script Helm has a provided script that will install Helm locally in bash. 
Manually The Helm binary can also be used to install Helm. 

```
# curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# helm version
# helm repo add stable https://charts.helm.sh/stable
# helm repo update
```
let create helm chart from scratch

first create the dir 
```
# mkdir -p helm/templates 
```
lets create the template file for mainfest 

the first one is deployment inside template dir 
```
# cat << EOF |  tee helm/templates/deployment.yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.deployment.name }}
  namespace: {{ .Values.deployment.namespace }}
  labels:
    app: {{ .Values.deployment.app }}
spec:
  replicas: {{ .Values.deployment.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.deployment.app }}
  template:
    metadata:
      labels:
        app: {{ .Values.deployment.app }}
    spec:
      securityContext:
        fsGroup: {{ .Values.deployment.fsGroup }}
        runAsUser: {{ .Values.deployment.runAsUser }}
      serviceAccountName: {{ .Values.deployment.serviceAccountName }}
      nodeSelector:
        app: {{ .Values.deployment.app }}
      containers:
      - name:  {{ .Values.deployment.name }}
        image: {{  .Values.deployment.image }}
        imagePullPolicy: {{.Values.deployment.imagePullPolicy }}
        securityContext:
          capabilities:
            add:
            - NET_RAW
        resources:
          {{- toYaml .Values.deployment.resources | nindent 12 }}
        readinessProbe:
          httpGet:
            path: {{  .Values.deployment.readinessProbe.httpGet.path }}
            port: {{  .Values.deployment.readinessProbe.httpGet.port }}
          initialDelaySeconds: {{.Values.deployment.readinessProbe.httpGet.initialDelaySeconds }}
          periodSeconds: {{  .Values.deployment.readinessProbe.httpGet.periodSeconds }}
EOF 
```
now will create the serivce 
```
cat << EOF |  tee helm/templates/services.yml 
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  namespace: {{ .Values.service.namespace }}
spec:
  selector:
    app: {{ .Values.service.app }}
  ports:
  - protocol: {{ .Values.service.protocol }}
    port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
EOF 
```
lets create the ingress controll 
```
# cat << EOF |  tee helm/templates/apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{  .Values.ingress.name   }}
  namespace: {{  .Values.ingress.namespace   }}
spec:
  ingressClassName: {{  .Values.ingress.ingressClassName   }}
  rules:
   {{- toYaml .Values.ingress.rules | nindent 2 }}
EOF
```
lets create the the serviceacount 

```
cat << EOF |  tee helm/templates/serviceacount.yml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.deployment.serviceAccountName }}
  namespace: {{ .Values.deployment.namespace }}
EOF
```

now will mapp the value of eche template inside values.yml file 
```
cat << EOF |  tee helm/service:
  name: restapi-helm
  namespace: helm
  app: restapi
  protocol: TCP
  port: 9098
  targetPort: 9098
deployment:
  name: restapi-deployment-helm
  namespace: helm
  app: restapi
  replicas: 2
  fsGroup: 65534
  runAsUser: 65534
  serviceAccountName: restapi-serviceaccount
  image: haydercyber/devops:restapi
  imagePullPolicy: Always
  resources:
    requests:
      memory: "64Mi"
      cpu: "250m"
    limits:
      memory: "128Mi"
      cpu: "500m"
  readinessProbe:
    httpGet:
      path: /healthcheck
      port: 9098
      initialDelaySeconds: 3
      periodSeconds: 3
ingress:
  name: ingress-helm
  namespace: helm
  ingressClassName: nginx
  rules:
  - host: "restapi.helm.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: restapi-helm
            port:
              number: 9098
EOF 
```
now will create Chart.yml file with version 
```
# cat << EOF |  tee helm/Chart.yaml
name: restapi
version: 1
EOF
```
lets dry run it to check it work or not 

```
# helm install demo helm/  --dry-run
```

``output``
```
NAME: demo
LAST DEPLOYED: Sun Mar 20 22:08:49 2022
NAMESPACE: default
STATUS: pending-install
REVISION: 1
TEST SUITE: None
HOOKS:
MANIFEST:
---
# Source: restapi/templates/serviceAccount.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: restapi-serviceaccount
  namespace: helm
---
# Source: restapi/templates/services.yml
apiVersion: v1
kind: Service
metadata:
  name: restapi-helm
  namespace: helm
spec:
  selector:
    app: restapi
  ports:
  - protocol: TCP
    port: 9098
    targetPort: 9098
---
# Source: restapi/templates/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: restapi-deployment-helm
  namespace: helm
  labels:
    app: restapi
spec:
  replicas: 2
  selector:
    matchLabels:
      app: restapi
  template:
    metadata:
      labels:
        app: restapi
    spec:
      securityContext:
        fsGroup: 65534
        runAsUser: 65534
      serviceAccountName: restapi-serviceaccount
      nodeSelector:
        app: restapi
      containers:
      - name:  restapi-deployment-helm
        image: haydercyber/devops:restapi
        imagePullPolicy: Always
        securityContext:
          capabilities:
            add:
            - NET_RAW
        resources:
            limits:
              cpu: 500m
              memory: 128Mi
            requests:
              cpu: 250m
              memory: 64Mi
        readinessProbe:
          httpGet:
            path: /healthcheck
            port: 9098
          initialDelaySeconds: 3
          periodSeconds: 3
---
# Source: restapi/templates/ingress.yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-helm
  namespace: helm
spec:
  ingressClassName: nginx
  rules:
  - host: restapi.helm.com
    http:
      paths:
      - backend:
          service:
            name: restapi-helm
            port:
              number: 9098
        path: /
        pathType: Prefix
```

lets deploy it and check it it working or not 


```
# helm install demo helm/
```
lets check the pods is run or not 

```
# kubectl get pods -n helm
```

``output``
```
restapi-deployment-helm-56c9b7fc95-6r8b2   0/1     ContainerCreating   0          11s
restapi-deployment-helm-56c9b7fc95-gj4v6   0/1     Running             0          11s
```
now lets check code func 

```
# curl -v restapi.helm.com/healthcheck
```
``output``
```
*   Trying 10.50.101.74...
* TCP_NODELAY set
* Connected to restapi.helm.com (10.50.101.74) port 80 (#0)
> GET /healthcheck HTTP/1.1
> Host: restapi.helm.com
> User-Agent: curl/7.61.1
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Sun, 20 Mar 2022 19:12:25 GMT
< Content-Type: text/plain; charset=utf-8
< Content-Length: 2
< Connection: keep-alive
<
* Connection #0 to host restapi.helm.com left intact
```

lets remove it 
```
#  helm delete demo
```
``output``
```
release "demo" uninstalled
```

Next : [Create CI/CD WITH GITLAB CI/CD](../README.md)