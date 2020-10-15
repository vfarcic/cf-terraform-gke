set -e

if [ "$1" == "" ]; then
  echo "Usage: $0 [CLUSTER_NAME] [REGION] [PROJECT_ID]"
  exit
fi

GET_CMD="gcloud container clusters describe $1 --region $2 --project $3"

echo "apiVersion: v1
kind: Config
current-context: my-cluster
contexts: [{name: my-cluster, context: {cluster: cluster-1, user: user-1}}]
users: [{name: user-1, user: {auth-provider: {name: gcp}}}]
clusters:
- name: cluster-1
  cluster:
    server: "https://$(eval "$GET_CMD --format='value(endpoint)'")"
    certificate-authority-data: "$(eval "$GET_CMD --format='value(masterAuth.clusterCaCertificate)'")"
" >kubeconfig.yaml

echo "Execute the following commands to use the newly created Kube config:"
echo
echo "export GOOGLE_APPLICATION_CREDENTIALS=account.json"
echo 
echo "export KUBECONFIG=$PWD/kubeconfig.yaml"

