# Google Cloud Kubernetes Engine (GKE) Cluster With Terraform And CodeFresh

## Pre-Work

* Infrastructure as Code, GitOps, CI/CD
* CodeFresh pipelines for PRs

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
terraform apply --var destroy=true

gcloud projects delete $PROJECT_ID
```

## Creating With CodeFresh

```bash
cat codefresh.yml

# Sign up or sign in

# Create a project

# Enter the project

# Create a pipeline
# Type *cf-terraform-gke* as the *pipeline name*
# Select *cf-terraform-gke*  as the repository
# Click the *CREATE* button

# If the error *You have not added your Git integration* appears, click the *Click here* link and follow the instructions.

# Change *Inline YAML* to *Use YAML from Repository*
# Click the *DONE* button
# Click the *SAVE* button

cat account.json

# Copy the output

# Click the *VARIABLES* tab
# Click the *ADD VARIABLE* button
# Type *ACCOUNT_JSON_CONTENT* as the *Key* and paste the JSON into the *Value* field
# Click the *Encrypt* button
# Click the *SAVE* button

# Click the *RUN* button

terraform refresh

gcloud container clusters \
    get-credentials \
    $(terraform output cluster_name) \
    --project \
    $(terraform output project_id) \
    --region \
    $(terraform output region)

kubectl get nodes

# Click the *TRIGGERS* tab

# Click the edit button of the only trigger
# Change the *TRIGGER NAME* to *master*
# Change *BRANCH (REGEX EXPRESSION)* to */master/gi*
# Click the *UPDATE* button

# Click the *+ ADD TRIGGER* button
# Choose *GIT*
# Click the *NEXT* button
# Type *pr-to-master* as the *TRIGGER NAME*
# Select *cf-terraform-gke* as the *REPOSITORY*
# Type */master/gi* as the *PULL REQUEST TARGET BRANCH (REGEX EXPRESSION)*
# Click the *NEXT* button

# TODO: PRs with `terraform init && terraform plan`

# TODO: Comment back the results to the PR

# TODO: Merge to master and observe the pipeline

# TODO: Do it through a PR.
# Change `destroy` to `true`.

git add .

git commit -m "Destroying everything"

git push
```

## Destroy With CodeFresh

```bash
# Change the `default` value of the variable `destroy` in `variables.tf` to `true`

git add .

git commit -m "Destroy everything"

git push
```