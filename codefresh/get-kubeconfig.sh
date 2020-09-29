set -e

terraform init

export CLUSTER_NAME=$(terraform output cluster_name)

export REGION=$(terraform output region)

export PROJECT_ID=$(terraform output project_id)

export KUBECONFIG=$PWD/kubeconfig.yaml

GET_CMD="gcloud container clusters describe $CLUSTER_NAME --region $REGION --project $PROJECT_ID"

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

kubectl apply --filename codefresh/create-cluster.yaml

export CURRENT_CONTEXT=$(kubectl config current-context)

set +e

codefresh delete cluster $CURRENT_CONTEXT

set -e

codefresh create cluster \
    --kube-context $CURRENT_CONTEXT \
    --serviceaccount codefresh \
    --namespace codefresh

echo 
echo 
echo "Execute the following commands to use the newly created Kube config:"
echo
echo "export GOOGLE_APPLICATION_CREDENTIALS=account.json"
echo 
echo "export KUBECONFIG=$PWD/kubeconfig.yaml"

