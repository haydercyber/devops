# Kubernetes
lso known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, combined with best-of-breed ideas and practices from the community 

> Deployments 
A Deployment provides declarative updates for Pods and ReplicaSets.
You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments



Use Case 

* Create a Deployment to rollout a ReplicaSet. The ReplicaSet creates Pods in the background. Check the status of the rollout to see if it succeeds or not.
* Declare the new state of the Pods by updating the PodTemplateSpec of the Deployment. A new ReplicaSet is created and the Deployment manages moving the Pods from the old ReplicaSet to the new one at a controlled rate. Each new ReplicaSet updates the revision of the Deployment.
* Rollback to an earlier Deployment revision if the current state of the Deployment is not stable. Each rollback updates the revision of the Deployment.
* Scale up the Deployment to facilitate more load.
* Pause the rollout of a Deployment to apply multiple fixes to its PodTemplateSpec and then resume it to start a new rollout.
* Use the status of the Deployment as an indicator that a rollout has stuck.
* Clean up older ReplicaSets that you don't need anymore.

Creating a Deployment 
The following is an `` go app ``  Deployment. It creates a ReplicaSet to bring up
```
# cat << EOF |  tee deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: restapi
  namespace: devops
  labels:
    app: restapi
spec:
  replicas: 1
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
      - name:  restapi
        image: haydercyber/devops:restapi
        imagePullPolicy: Always
        securityContext:
          capabilities:
            add:
            - NET_RAW
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
EOF 

```
`` Explain The  manifest contexts ``
* A Deployment named `` restapi  `` in namespace ``devops ``
    * `` Namespaces `` are a way to organize clusters into virtual sub-clusters
* ``Label`` Labels are key/value pairs that are attached to objects, such as pods ``app=restapi``
* the ``.spec.replicas`` The Deployment creates one replicated Pods
* The ``.spec.selector``  field defines how the Deployment finds which Pods to manage. In this case, you select a label that is defined in the Pod template  ``app: restapi``  However, more sophisticated selection rules are possible, as long as the Pod template itself satisfies the rule 
* The ``template`` field contains the following sub-fields: 
    * The Pods are labeled ``app: restapi`` using the ``.metadata.labels`` field.
    * the `` .spec.securityContext`` Discretionary Access Control: Permission to access an object, like a file, is based on user ID (UID) and group ID (GID). in our case will use the id and group id of user ``nobody:nobody``
    * the ``.spec.serviceAccountName `` A service account provides an identity for processes that run in a Pod. we will explin few letter 
    * the ``.spec.nodeSelector`` is the simplest recommended form of node selection constraint. ``nodeSelector`` is a field of PodSpec. It specifies a map of ``key-value`` pairs. For the pod to be eligible to run on a node, the node must have each of the indicated key-value pairs as labels (it can have additional labels as well). The most common usage is one ``key-value pair``. lets create label in one of node in my cluster 
    ```
    # kubectl label nodes k8snode2 app=restapi
    ```
    that mean the pods will run and deployed on `` k8snode2  `` 
    * The Pod template's specification, or `` .template.spec `` field, indicates that the Pods run one container, ``haydercyber/devops:restapi`` run `` haydercyber/devops`` `` Docker Hub``  image tag ``restapi `` that we have push to docker hub abouve 
    * Create one container and name it `` restapi``
    * the `` imagePullPolicy``  for a container and the tag of the image affect when the kubelet attempts to pull (download) the specified image am useing `` Always``  every time the kubelet launches a container, the kubelet queries the container image registry to resolve the name to an image digest. If the kubelet has a container image with that exact digest cached locally, the kubelet uses its cached image; otherwise, the kubelet pulls the image with the resolved digest, and uses that image to launch the container. i have use to achive the ci/cd when the dev persion push the change and build image thin k8s pull from repostriy 
    * the `` .spec.resources `` If the node where a Pod is running has enough of a resource available, it's possible (and allowed) for a container to use more resource than its ``request`` for that resource specifies. However, a container is not allowed to use more than its resource ``limit``
    * the  `` readinessProbe `` The kubelet uses readiness probes to know when a container is ready to start accepting traffic. A Pod is considered ready when all of its containers are ready in my code ``There’s a single Counter metric called http_requests_total (the “total” suffix is a naming convention) with a constant label {server="api"}. The HealthCheck() HTTP handler itself will call the Inc() method responsible for incrementing this counter, but in a real-life application that would preferable be done in a HTTP middleware. ``
    field contains the following sub-fields: 
        * In the configuration file, you can see that the Pod has a single container. The ``periodSeconds`` field specifies that the kubelet should perform a liveness probe every ``3`` seconds. The ``initialDelaySeconds`` field tells the kubelet that it should wait ``3`` seconds before performing the first probe. To perform a probe, the kubelet sends an HTTP GET request to the server that is running in the container and listening on port `` 9098 `` If the handler for the server's  ``/healthcheck `` path returns a success code, the kubelet considers the container to be alive and healthy. If the handler returns a failure code, the kubelet kills the container and restarts it. 

let create deployment the deployment shuld not work becuse i have assing serviceAccount `` restapi-serviceaccount `` but i didnet create this  servicesAcount lets see 

```
# kubectl apply -f deployment.yml
```
``output `` 
```
deployment.apps/restapi created
```
lets inspect pods in namespace `` devops  `` 
```
# kubectl get pods -n devops 
```
``output``
```
No resources found in devops namespace
```
its means no pods running in this namespace lets inspect the deployment 

```
# kubectl describe deployments.apps -n devops restapi 
```
`` output`` 
```
Name:                   restapi
Namespace:              devops
CreationTimestamp:      Sat, 19 Mar 2022 21:12:13 +0300
Labels:                 app=restapi
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=restapi
Replicas:               1 desired | 0 updated | 0 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:           app=restapi
  Service Account:  restapi-serviceaccount
  Containers:
   restapi:
    Image:      haydercyber/devops:restapi
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        250m
      memory:     64Mi
    Readiness:    http-get http://:9098/healthcheck delay=3s timeout=1s period=3s #success=1 #failure=3
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type             Status  Reason
  ----             ------  ------
  Available        False   MinimumReplicasUnavailable
  ReplicaFailure   True    FailedCreate
  Progressing      False   ProgressDeadlineExceeded
OldReplicaSets:    <none>
NewReplicaSet:     restapi-67579d5c88 (0/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  28m   deployment-controller  Scaled up replica set restapi-67579d5c88 to 1
```
lets check if the are any serviceacount with this name `` restapi-serviceaccount ``
```
# kubectl get serviceaccounts --all-namespaces  | grep "restapi-serviceaccount"
```
`` output ``
```
empty 
```
lets create serviceAccount with Role and ClusterRole

> serviceAccount 
A service account provides an identity for processes that run in a Pod. 
When you (a human) access the cluster (for example, using kubectl), you are authenticated by the apiserver as a particular User Account (currently this is usually admin, unless your cluster administrator has customized your cluster). Processes in containers inside pods can also contact the apiserver. When they do, they are authenticated as a particular Service Account (for example, default). lets create serviceaccount 
```
# cat << EOF |  tee serviceAccount.yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: restapi-serviceaccount
  namespace: devops
EOF
```
let apply it 
```
# kubectl apply -f serviceAccount.yaml
```
let check the deployment it should work now 

```
# kubectl get pods -n devops
```
``output``
```
restapi-67579d5c88-9sf8r   1/1     Running   0          53s
```
lets   check the func for ``app`` with debug `` continers``
let get the ip of pod to check it 
```
# kubectl get pods -n devops  -o wide
```
``output``
```
NAME                       READY   STATUS    RESTARTS   AGE     IP                NODE       NOMINATED NODE   READINESS GATES
restapi-67579d5c88-9sf8r   1/1     Running   0          6m22s   192.168.185.198   k8snode2   <none>           <none>
```
let run single curl command 
```
# kubectl run -it --tty netshoot -n devops --image=nicolaka/netshoot --restart=Never --rm -- curl 192.168.185.198:9098/health
check
```

``output``
```
OK
pod "netshoot" deleted
```
now is everything is work lets create Role and ClusterRole 

>  Role and ClusterRole 
An RBAC Role or ClusterRole contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).
A Role always sets permissions within a particular namespace; when you create a Role, you have to specify the namespace it belongs in.
ClusterRole, by contrast, is a non-namespaced resource. The resources have different names (Role and ClusterRole) because a Kubernetes object always has to be either namespaced or not namespaced; it can't be both.
ClusterRoles have several uses. You can use a ClusterRole to:
* define permissions on namespaced resources and be granted within individual namespace(s)
* define permissions on namespaced resources and be granted across all namespaces
* define permissions on cluster-scoped resources
lets create the clusterrole and clusterrolebinding only in my case 
```
# cat << EOF |  tee cr.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: restapi
rules:
  - apiGroups: [""]
    resources:
    - nodes
    - nodes/proxy
    - services
    - endpoints
    - pods
    verbs: ["get", "list", "watch" ]
  - apiGroups:
    - extensions
    resources:
    - ingresses
    verbs: ["get", "list", "watch"]
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
  - nonResourceURLs: ["/healthcheck"]
    verbs: ["get"]
EOF
```
`` Explain The  manifest contexts `` 
In the role, given below, you can see that we have added get, list, and watch permissions to ``nodes``, ``services`` ``endpoints``, ``pods``, and ``ingresses``. The role binding is bound to the monitoring namespace. If you have any use case to retrieve metrics from any other object, you need to add that in this cluster role.

lets apply it 
```
# kubectl apply -f cr.yml
```
lets bind this role with serviceaccount by create clusterrolebinding

```
# cat << EOF |  tee crb.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: restapi
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: restapi
subjects:
- kind: ServiceAccount
  name: restapi-serviceaccount
  namespace: devops[root@devops k8s]# cat crb.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: restapi
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: restapi
subjects:
- kind: ServiceAccount
  name: restapi-serviceaccount
  namespace: devops
EOF
```
```
# kubectl apply -f crb.yml
```
now lets expose the deployment with services 

> Services : An abstract way to expose an application running on a set of Pods as a network service.
With Kubernetes you don't need to modify your application to use an unfamiliar service discovery mechanism. Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them

lets create service 
```
# cat << EOF |  tee service.yml
apiVersion: v1
kind: Service
metadata:
  name: restapi-services
  namespace: devops
spec: 
  selector:
    app: restapi
  ports:
  - protocol: TCP
    port: 9098
    targetPort: 9098
EOF 
```
`` Explain The  manifest contexts ``

This specification creates a new Service object named `` restapi-services `` in namespace `` devops ``  
which targets TCP port  ``9098`` with spefic label `` app: restapi`` in `` .spec.selector`` Publishing Services  For some parts of your application (for example, frontends) you may want to expose a Service onto an external IP address, that's outside of your cluster.
Kubernetes ServiceTypes allow you to specify what kind of Service you want. The default is ClusterIP.  
will expose ClusterIP to client vi ingress control

lets test the service its work or not let debig it 
```
# kubectl get svc -n devops
```
``output``
```
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
restapi-services   ClusterIP   10.111.177.191   <none>        9098/TCP   8s
```
```
# kubectl run -it --tty netshoot -n devops --image=nicolaka/netshoot --restart=Never --rm -- curl 10.111.177.191:9098/healthcheck
```
``output``
```
OK
pod "netshoot" deleted
```
> NGINX Ingress Controller is
The vast majority of Kubernetes clusters are used to host containers that process incoming requests from microservices to full web applications. Having these incoming requests come into a central location, then get handed out via services in Kubernetes, is the most secure way to configure a cluster. That central incoming point is an ingress controller.
The most common product used as an ingress controller for privately-hosted Kubernetes clusters is NGINX. NGINX has most of the features enterprises are looking for, and will work as an ingress controller for Kubernetes regardless of which cloud, virtualization platform, or Linux operating system Kubernetes is running on.
In this blog post we will go over how to set up an NGINX Ingress Controller using two different methods.
An ingress controller, because it is a core component of Kubernetes, requires configuration of more moving parts of the cluster than just deploying a pod and a route.
In the case of NGINX, its recommended configuration has three ConfigMaps:
* Base Deployment
* TCP configuration
* UDP configuration

A service account to run the service is within the cluster, and that service account will be assigned a couple roles.
A cluster role is assigned to the service account, which allows it to get, list, and read the configuration of all services and events. This could be limited if you were to have multiple ingress controllers. But in most cases, that is overkill.
A namespace-specific role is assigned to the service account to read and update all the ConfigMaps and other items that are specific to the NGINX Ingress controller’s own configuration.
The last piece is the actual pod deployment into its own namespace to make it easy to draw boundaries around it for security and resource quotas.
The deployment specifies which ConfigMaps will be referenced, the container image and command line that will be used, and any other specific information around how to run the actual NGINX Ingress controller.
> Install via CLI 
```
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml
```
> Exposing the NGINX Ingress Controller
Once the base configuration is in place, the next step is to expose the NGINX Ingress Controller to the outside world to allow it to start receiving connections. This could be through a load-balancer like on AWS, GCP, Azure, or BareOS with MetalLB. The other option when deploying on your own infrastructure without MetalLB, or a cloud provider with less capabilities, is to create a service with a NodePort to allow access to the Ingress Controller.

LoadBalancer
```
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml

```
NodePort
Using the NGINX-provided service-nodeport.yaml file, which is located on GitHub, will define a service that runs on ports 80 and 443. It can be applied using a single command line, as done before.
```
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/baremetal/deploy.yaml
```
The final step is to make sure the Ingress controller is running.

```
# kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx
```

``output``
```
NAMESPACE       NAME                                       READY   STATUS      RESTARTS   AGE
ingress-nginx   ingress-nginx-admission-create-g7gk4       0/1     Completed   0          58m
ingress-nginx   ingress-nginx-admission-patch-tsss5        0/1     Completed   1          58m
ingress-nginx   ingress-nginx-controller-c789df69d-5wbzr   1/1     Running     0          58m
```
let patch the extrnal ip of my node to map to ingress controll i will my ip for node `` 10.50.101.74 `` then i will mapping useing /etc/hosts to act like realy dns with name iwill provide 
```
# cat << EOF |  tee external-ips.yaml
spec:
  externalIPs:
  - 10.50.101.74
EOF 
```
lets patch it 
```
# kubectl patch service -n ingress-nginx ingress-nginx-controller --patch-file=external-ips.yaml
```
``output``
```
service/ingress-nginx-controller patched
```
lets create ingress control 
```
# cat << EOF |  tee 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: devops
spec:
  ingressClassName: nginx
  rules:
  - host: "restapi.go.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: restapi-services
            port:
              number: 9098
EOF 
```
As with all other Kubernetes resources, an Ingress needs ``apiVersion``, ``kind``, and ``metadata`` fields. The name of an Ingress object must be a valid DNS subdomain name. For general information about working with config files, see deploying applications, configuring containers, managing resources. Ingress frequently uses annotations to configure some options depending on the Ingress controller, an example of which is the rewrite-target annotation. Different Ingress controllers support different annotations. Review the documentation for your choice of Ingress controller to learn which annotations are supported.
Ingress rules
Each HTTP rule contains the following information:
* An optional host. In this example, no host is specified, so the rule applies to all inbound HTTP traffic through the IP address specified. If a host is provided ``restapi.go.com``, the rules apply to that host.
*  each of which has an associated backend defined with a ``service.name``, ``restapi-services `` and a ``service.port.name`` or ``service.port.number`` `` 9098 ``. Both the host and path must match the content of an incoming request before the load balancer directs traffic to the referenced Service.
* A ``backend`` is a combination of Service and port names   by way of a ``CRD``. ``HTTP`` ``(and HTTPS)`` requests to the Ingress that matches the host and path of the rule are sent to the listed ``backend``.

lets test before apply first iwill add `` 10.50.101.74 `` mapping `` restapi.go.com ``  that ip is for node that have label ``app: restapi`` you have add to node `` k8snode1 `` iwill use his extrnal ip to do the test 

```
# echo "10.50.101.74 restapi.go.com" >> /etc/hosts
```
lets send curl request before apply the ingress it shouldnot work 

```
curl restapi.go.com/healthcheck
```

``output``
```
error: timed out waiting for the condition
```

lets apply it to see it work 
```
# kubectl apply -f ingress.yml
```

`` output``

```
OK
```
its work  
NEXT: [helm]()