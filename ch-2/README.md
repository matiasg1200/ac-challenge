## CI/CD with GCP

### Deploy

run the terraform code to create the following resoruces 
- Cloud Source repository
- Cloud Build trigger to create image from compute instances
- Cloud Build trigger for cicd pipepiline to deploy sample Python application to Cloud Run

### Kickoff CICD Pipelines 

Initially the repo is created empty so to get the builds running for the first time you will have to manually push to the repo. 

Your first commit should have the contents from this direcroty only (ch-2) 

Following these steps should clone the repo, copy neccesary files and then push

> in order to be able to push make sure you have propper permissions: https://cloud.google.com/source-repositories/docs/creating-an-empty-repository#gcloud

```
repo=$(pwd)

cd ~

git clone https://source.developers.google.com/p/<your_gcp_project>/r/GCP_CloudBuild_Exercises

cp -r $repo/* prueba/

cd GCP_CloudBuild_Exercises

git add . && git commit -m "first commit"

git push -u origin master
```

You can also follow these instructions to make your first commit: https://source.cloud.google.com/neon-alcove-412113/GCP_CloudBuild_Exercises?hl=en

copy only the files under the directory ch-2 to the new repo

### CICD Workflow

Once you've made your first push that should trigger a build from the `cicd-sample-app` trigger. This will run the following steps:
- Run a unit test 
- After succeful test build a new image
- Push the image to GCR
- Deploy to Cloud Run

### Image creation Workflow

Once you've made your first push that should trigger a build from the `create-image` trigger. This will run the following steps:
- Stop the compute engine instance
- Create an image from the compute engine instance
- Start the compute engine instance