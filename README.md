## Still WIP

### ch-1 
Directory continas terraform code to create Windows VM instances and Cloud Storage bucket that stores the startup script which will install the requested packages. It also has a logic to create a key-pair and write the private key to a file and public file to different file, to manage ssh access to the Windows instance. Once the resources are created, the private key should be uploaded to the server and the public key shared with the engineers that need access to it.

### ch-2 
contains terraform code to create to create the following resoruces: 
- Cloud Source Repositoty code repo
- Artifact Registry artifact repo
- Cloud Build trigger 

It also contains the cloudbuild.yaml file that sets up the ci/cd pipeline to deploy to the compute engine instance

___
## Missing at this point:
- configure cloudbuild.yaml file to deploy to compute engine instance
- setup a second trigger for the second required target
- integrate secrets manager 
- configuring variables and outputs on terraform code to avoid hardcoded values
- maybe try to create a module for each ch or one for both (still didn't think this through)
