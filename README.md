# Google Cloud Kubernetes Engine (GKE) Cluster With Terraform And CodeFresh

## Preparing

```bash
open https://github.com/vfarcic/cf-terraform-gke

# Fork it

export GH_USER=[...]

git clone https://github.com/$GH_USER/cf-terraform-gke

cd cf-terraform-gke

cp orig/*.tf .

gcloud auth login

export PROJECT_ID=doc-$(date +%Y%m%d%H%M%S) # e.g., doc-cf-project

gcloud projects create $PROJECT_ID

gcloud iam service-accounts \
    create devops-catalog \
    --project $PROJECT_ID \
    --display-name devops-catalog

gcloud iam service-accounts \
    keys create account.json \
    --iam-account devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --project $PROJECT_ID

gcloud projects \
    add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:devops-catalog@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/owner

open https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID

# Link a billing account

export BUCKET_NAME=doc-$(date +%Y%m%d%H%M%S) # e.g., doc-cf-bucket

export REGION=us-east1

gsutil mb \
    -p $PROJECT_ID \
    -l $REGION \
    -c "NEARLINE" \
    gs://$BUCKET_NAME

cat variables.tf

gcloud container get-server-config \
    --project $PROJECT_ID \
    --region $REGION

# Select one of `validMasterVersions` values.
# Select any version except the newest

export VERSION=[...]

cat variables.tf \
    | sed -e "s@CHANGE_PROJECT_ID@$PROJECT_ID@g" \
    | sed -e "s@CHANGE_VERSION@$VERSION@g" \
    | tee variables.tf

cat main.tf

cat main.tf \
    | sed -e "s@CHANGE_BUCKET@$BUCKET_NAME@g" \
    | tee main.tf

cat output.tf

git add .

git commit -m "Initial commit"

git push
```

## Creating Manually

```bash
terraform init

terraform apply

export KUBECONFIG=$PWD/kubeconfig

kubectl get nodes
```

## Destroy Manually

```bash
# TODO: Change variables

terraform apply --var destroy=true

gcloud projects delete $PROJECT_ID
```

## Creating With CodeFresh

```bash
# Sign in

# Create a project

# Enter the project

# Create a pipeline
# Type *cf-terraform-gke* as the *pipeline name*
# Select *cf-terraform-gke*  as the repository
# Click the *CREATE* button

# If the error *You have not added your Git integration* appears, click the *Click here* link and follow the instructions.
# If the error *'registry' is required* appears, click the *Click here* link and follow the instructions.

# Change *Inline YAML* to *Use YAML from Repository*
# Click the *DONE* button
# Click the *SAVE* button

cat account.json

# Copy the output

# Click the *VARIABLES* tab
# Click the *ADD VARIABLE* button
# Type *ACCOUNT_JSON_CONTENT* as the *Key* and paste the JSON into the *Value* field
# Click the *SAVE* button

# TODO: Switch to secrets

terraform refresh

gcloud container clusters \
    get-credentials \
    $(terraform output cluster_name) \
    --project \
    $(terraform output project_id) \
    --region \
    $(terraform output region)
```