curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.16 > asmcli
chmod +x asmcli

#
#
#
#


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



GATEWAY_NS=istio-gateway
kubectl create namespace $GATEWAY_NS

kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}'

REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')

kubectl label namespace $GATEWAY_NS \
istio.io/rev=$REVISION --overwrite


kubectl apply -n $GATEWAY_NS \
  -f asm_output/samples/gateways/istio-ingressgateway


kubectl label namespace default istio-injection- istio.io/rev=$REVISION --overwrite