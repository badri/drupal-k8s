# Dev Days Lisbon 2018 Kubernetes workshop

Held [here](https://lisbon2018.drupaldays.org/sessions/helmsman-and-water-drop-running-drupal-kubernetes).

## Prerequisites

Make sure you have the following installed on your local machine:

 - Docker: For building your container images and pushing them to a docker registry of choice.
 - Minikube: For running a local 1-node K8s cluster
 - Kubectl: For communicating with different k8s clusters
 
## Minikube setup

Boot minikube.

```
minikube start
```

You can check status of your minikube cluster by running,

```
minikube status
```

## Build a Hello World PHP docker image

This is just to get the hang of deploying a small application using k8s. Substitute `<namespace>` with your Dockerhub namespace in all commands.

```
cd k8s/minikube-hello-world

docker build <namespace>/php-k8s:v1 .
```

Push your image to Dockerhub public registry. Make sure you have logged in to your Dockerhub account using `docker login`.

```
docker push <namespace>/php-k8s:v1
```

## Deploy your first application to K8s

Pods are the basic units of a K8s cluster.

```
kubectl get pods
```

You should get "no resources found".

Deploy the image we previously created

```
kubectl run hello-world --image=<namespace>/php-k8s:v1 --port=8080
```

Expose your pods to outside world using services.

```
kubectl expose deployment hello-world --type=LoadBalancer
```

Open service in browser.

```
minikube service hello-world
```

## Deploy the same application using YAML manifests

Apply the deployment.

```
cd k8s/minikube-hello-world
kubectl apply -f deployment.yml 
```

Apply the service.

```
kubectl apply -f service.yml 
```
### Get the name of a pod

First, get the list of pods.

```
kubectl get po

NAME                                          READY     STATUS    RESTARTS   AGE
drupal-56f6c47f76-l8fkn                       1/1       Running   0          1h
hello-world-6686ff999b-wh2tr                  1/1       Running   0          2h
mysql-7fd9c8467d-22zg4                        1/1       Running   0          1h
php-hello-world-deployment-78dc8f54cc-9jkf8   1/1       Running   0          2h
php-hello-world-deployment-78dc8f54cc-wkdtc   1/1       Running   0          2h
php-hello-world-deployment-78dc8f54cc-zzgnt   1/1       Running   0          2h
```

The first column is the pod name. Substitute `<pod-name>` with the pod name you want in upcoming commands.

### Delete a pod

We have set a replication factor of 3 for the hello-world PHP pod. Let's try to delete one of the pods.

```
kubectl delete pods <pod-name>
```

K8s will automatically re-provision a new pod to maintain the replication factor of 3.

### Deploy a new image

```
cd k8s/minikube-hello-world
```

Change the `index.php` to add some text.

Rebuild the new image.

```
docker build -t <namespace>/php-k8s:v2
```

Push to Docker Registry.

```
docker push <namespace>/php-k8s:v2
```


Open `deployment.yml` and edit the image to point to new version,

```yaml
    spec:
      containers:
      - name: php-hello-world
        image: <namespace>/php-k8s:v2
        ports:
        - containerPort: 8080

```

And apply the deployment again.

```
kubectl apply -f deployment.yml 
```

Verify that your change is reflected by visiting the service.

```
minikube service php-hello-world-svc # this is the service name you have in service.yml file
```

## Deploy Drupal 8 on Minikube

Drupal and MySQL have persistent volumes. K8s is a container based system, so no data is persisted and pods are ephermeral, like containers. We use a new set of resources called volumes and volume claims to persist app data between deployments.

### Create persistent volumes

```
cd k8s/minikube-compact
kubectl apply -f local-volumes.yml
```

Get the volumes in system using,

```
kubectl get pv
```

### Create a MySQL related secret(password)

Instead of openly adding the MySQL password, we create a new K8s construct called `secret`.

```
kubectl create secret generic mysql --from-literal=password=<your-mysql-password>
```

### Apply a MySQL deployment

This will create the pods, services and volume claims associated with the database.

```
kubectl apply -f mysql-deployment.yml
```

Check the persistent volume claim by running,

```
kubectl get pvc
```

### Create Drupal image

Go to the top level directory in the repo you cloned and run,

```
docker build -t <namespace>/drupal-8:plain-1
```

Visit the `Dockerfile` at the top level directory to see how the image is built, and to make any needed changes.

Push to registry.

```
docker push <namespace>/drupal-8:plain-1
```

### Apply a Drupal deployment

```
cd k8s/minikube-compact
```

Change the image if needed in the deployment manifest,

```yaml
  template:
    metadata:
      labels:
        app: drupal
    spec:
      containers:
        - image: <namespace>/drupal-8:plain-1
          name: drupal
          env:
```

Apply deployment.

```
kubectl apply -f drupal-deployment.yml
```

### Get logs of a pod

To tail the pod logs,

```
kubectl logs -f <pod-name>
```

### Describe a pod

to show the status, history of state and other metadata associated with a pod.

```
kubectl describe po <pod-name>
```

### Using drush inside a pod

To ssh into your pod,

```
kubectl exec -it <pod-name> -- /bin/bash
```

```
./vendor/bin/drush si --db-url="mysql://root:<password-you-gave-when-creating-secret>/drupal8" -y
```

Make sure you copy the admin password drush site-install generates for you.

Exit shell and run Drupal.

```
minikube service drupal # the service name you gave in drupal-deployment.yml
```

### Deploy a change to Drupal in Minikube

Let's make a change on our codebase, like download the devel module.

Go to the top level directory, and run

```
composer require drupal/devel
```

Build a new version of docker image,

```
docker build -t <namespace>/drupal-8:plain-2
```

Push to registry,

```
docker push <namespace>/drupal-8:plain-2
```

Change the image in deployment manifest and apply new deployment, as mentioned in the "Apply a Drupal deployment" section above.


Confirm that devel module is present in the modules/extend page.

```
minikube service drupal
```

## TODO

- Create K8s cluster on a cloud provider
- Deploy Drupal in a K8s cluster running in the cloud
- Point to a domain/create ingress

## Contact
Please mail to "lakshmi@lakshminp.com" with "k8s workshop" in the subject.
