# Anthos Service Mesh on GKE Cluster
Anthos Service Mesh is a suite of tools that helps you monitor and manage a reliable service mesh on-premises or on Google Cloud.

### 1 - Prepare your environment:
- Login to GCP: `gcloud auth login`

- Set default project: `gcloud config set project [project_id]`

- Check everything is going well: `gcloud auth list` & `gcloud config list`

- Configure environment variables:
```
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")
export CLUSTER_NAME=central
export CLUSTER_ZONE=us-west1-c
export WORKLOAD_POOL=${PROJECT_ID}.svc.id.goog
export MESH_ID="proj-${PROJECT_NUMBER}"
```

### 2 - Set up GKE cluster:
- Install infrastructure using terraform:
```
cd Terraform
terraform init                     #initializes a working directory and installs plugins for google provider
terraform plan                     #to check the changes
terraform apply -auto-approve      #creating the resources on GCP
```
_OR_

- Install infrastructure using Cloud shell:
```
gcloud config set compute/zone ${CLUSTER_ZONE}
gcloud beta container clusters create ${CLUSTER_NAME} \
    --machine-type=n1-standard-4 \
    --num-nodes=2 \
    --workload-pool=${WORKLOAD_POOL} \
    --enable-stackdriver-kubernetes \
    --subnetwork=default \
    --release-channel=regular \
    --labels mesh_id=${MESH_ID}
```
- Ensure you have the cluster-admin role on your cluster:
```
kubectl create clusterrolebinding cluster-admin-binding   --clusterrole=cluster-admin   --user=$(whoami)
```
- Configure kubectl to point to the cluster:
```
gcloud container clusters get-credentials ${CLUSTER_NAME} \
     --zone $CLUSTER_ZONE \
     --project $PROJECT_ID
```

### 3 - Prepare to install Anthos Service Mesh:
- Google provide a tool called `asmcli` to manage Anthos Service Mesh. We will install it:
```
curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.16 > asmcli
chmod +x asmcli
gcloud services enable mesh.googleapis.com
```

### 4 - Install Anthos Service Mesh:
```
./asmcli install \
  --project_id $PROJECT_ID \
  --cluster_name $CLUSTER_NAME \
  --cluster_location $CLUSTER_ZONE \
  --fleet_id $PROJECT_ID \
  --output_dir ./asm_output \
  --enable_all \
  --option legacy-default-ingressgateway \
  --ca mesh_ca \
  --enable_gcp_components
```

### 5 - Install an ingress gateway:
- Create namespace:
```
GATEWAY_NS=istio-gateway
kubectl create namespace $GATEWAY_NS
```
- Locate the revision label on `istiod` and store it in an environment variable:
```
REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')
kubectl label namespace $GATEWAY_NS \
istio.io/rev=$REVISION --overwrite
```
- deploy the example ingress gateway configuration:
```
kubectl apply -n $GATEWAY_NS \
  -f asm_output/samples/gateways/istio-ingressgateway
```
### 6 - Enable sidecar injection:
- Anthos Service Mesh uses sidecar proxies to enhance network security, reliability, and observability. 
With Anthos Service Mesh, these functions are abstracted away from an application's primary container and implemented in a common out-of-process proxy delivered as a separate container in the same Pod.
```
kubectl label namespace default istio-injection- istio.io/rev=$REVISION --overwrite
```

### 7 - Deploy Bookinfo, an Istio-enabled multi-service application:
- Clone the repo: `git clone https://github.com/istio/istio.git`
- Deploy the application:
```
cd istio-1.16.2-asm.2
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

### 8 - Enable external access using an Istio Ingress Gateway:
```
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

### 9 - Verify the application deployments:
- Confirm services has been deployed correctly: `kubectl get services`
- Confirm running application pods: `kubectl get pods`
- Confirm the ingress gateway has been created: `kubectl get gateway`
- Get the external IP address of the ingress gateway: `kubectl get svc istio-ingressgateway -n istio-system`

### 10 - Access application from browser:
- Check your application at: `http://[EXTERNAL-IP]/productpage`

![Result](https://github.com/Abdullah-Elkasaby/GCP-Project-Group-5/assets/45972231/06596626-cdaf-43e1-ac83-64456d3ca793)
