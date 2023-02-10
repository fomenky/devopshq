# Jenkins Repo

Jenkins is a powerful automation tool that facilitates the continuous integration and delivery workflow for almost any environment using pipelines, as well as automating other routine development or devops provisioning tasks.

The Jenkins Continuous Integration and Delivery server

# How We Use Jenkins
Jenkins is open source and is available as a Java 8 WAR archive. 
It can be ran on the major operating systems, as well as on a Docker image.

At GetBusy, Jenkins runs on docker inside an EC2 instance.

Because Jenkins runs on docker, in order to backup the Jenkins home directory where our configuration files are stored, we create a local directory called '/var/jenkins_home' on the EC2 instance and bind it to the docker container.  
We later on sync the contents of the local directory to an s3 bucket.
The beauty of this is, we can start/stop/delete the jenkins container at any time and we won't a thing.
This makes updating seemless. 

For details, see cloudformation template: jenkins-master.yml

## Proposed Usage

At SmartVault, Jenkins pipelines can be used for:

- deploying windows updates

- triggering a teamcity deployment/rollout step

- codedeploy

- automating dev/devops tasks 

- automating all IaC - cloudformation, terraform, packer and ansible - jobs    

## Benefits

Save time deploying, spend time writing code.

With the availability of multiple plugins, we can easily improve our deployment process

With pipelines, you can review your code on the pipeline and extract any needed data from the output needed for another automation job

With pipelines, you can also audit stages in your pipeline by accepting or rejecting a deployment before resuming 

Pipelines are robust. So if the docker image undergoes an unforeseen restart, the pipeline will be automatically resumed

Lastly, pipelines are implemented as code which allows multiple users to edit and execute the pipeline process.

Thus, there is a singular source for a specific pipeline and can be modified by multiple users.


# Directories

## Docker (Jenkins Docker Image)

This is where the jenkins dockerfile and other configuration files such as packer is stored

### Provisioning
To build/update the Jenkins docker image, just update the Dockerfile and build it.

For details, see the README.md file in the docker folder.

NOTE: This image contains the packer tools needed to deploy windows updates to AWS.
More tools or configuration files can be installed or added to this image as need be. 
Just be sure to build and push image to the respective ECR repository.

PS: The golden jenkins image is tagged latest and stored securely in ECR (450560603497.dkr.ecr.us-east-2.amazonaws.com/smartvault.devops.jenkins:latest)

### Structure
```
.
docker
├── Dockerfile
├── LICENSE.txt
├── Makefile
├── README.md
├── files
│   ├── packer-tools
│   │   ├── packer.py
│   │   ├── provisioners
│   │   │   └── ansible
│   │   │       ├── ansible-galaxy-wrapper.sh
│   │   │       └── ansible-wrapper.sh
│   │   ├── rsa_key.pem
│   │   ├── smartvault-production-us-east-2.pem
│   │   ├── smartvault-staging-us-east-2.pem
│   │   ├── ssh-wrapper.sh
│   │   └── userdata
│   │       ├── prod
│   │       │   ├── tagging.tfvars.json
│   │       │   ├── terraform.tfvars.json
│   │       │   └── us-east-2.tfvars.json
│   │       ├── staging
│   │       │   ├── tagging.tfvars.json
│   │       │   ├── terraform.tfvars.json
│   │       │   └── us-east-2.tfvars.json
│   │       └── userdata.ps1
│   └── terraform
│       ├── README.md
│       ├── bin
│       │   ├── tfdestroy.sh
│       │   ├── tfplan.sh
│       │   └── tfprovision.sh
│       └── lib
│           └── tflib.sh
├── install-plugins.sh
├── jenkins-support
├── jenkins.sh
├── plugins.sh
├── publish-experimental.sh
├── publish.sh
├── tini-shim.sh
└── tini_pub.gpg
```


## Cloudformation

This is where cloudformation templates and their respective environment parameters are stored. 

### Provisioning

After the jenkins docker image is pushed to ecr, you can start using jenkins.

To start using Jenkins we'd need to provision the needed resources which include: ec2, s3, ELB, route53 and IAM/security groups. 
EX (smartvault):
```
cd /<PATH-TO-CLONED-JENKINS-REPO>/jenkins/cloudformation;
aws cloudformation create-stack \
 --stack-name smartvault-<EnvId>-jenkins \
 --template-body file:///<PATH-TO-LOCAL-JENKINS-REPO>/jenkins/cloudformation/jenkins/jenkins-master.yml \
 --parameters file:///<PATH-TO-LOCAL-JENKINS-REPO>/jenkins/cloudformation/jenkins-params.json \
 --profile <enter-profile> \
 --region <enter-region> \
 --capabilities CAPABILITY_NAMED_IAM
```
NOTE: This task can be automated as a single job in jenkins using job DSL 

After resources are created, visit http://jenkins.int.stg.smartvault.com to setup an admin user and configure default plugins.

EX:
```
Username: admin
Password: password
Confirm password: password
Full name: Administrator
E-mail address: devops@smartvault.com
```

After resources are created, visit http://jenkins.int.smartvault.com to setup user and configure default pipelines and plugins.
Wait for bucket sync to complete and retrieve initial password from ..secrets/initialAdminPassword 

Select 'Install suggested plugins' to get started.

PS: For an improved user experience, install the blue ocean plugin. 

Manage Jenkins > Click tab Available > Select 'Blue Ocean' > Install without restart 

NOTE: Configuring jenkins plugins can be performed in the Dockerfile (To Do) but unlocking and setting up admin users is best to be performed manually.

### Structure
```
.
cloudformation
├── jenkins-master.yml
├── jenkins-params.json
└── smartvault
    ├── dev
    ├── prd
    │   └── terraform-remote-state-params.json
    ├── stg
    │   └── terraform-remote-state-params.json
    └── terraform-remote-state.yml
```


## Terraform

Terraform is a tool used to provision environment resources. 
This is where terraform config files are stored 

### Provisioning
The resources being provisioned so far are the terraform-packer-tools.
Located in the terraform-provision-packer directory, this is what provisions the resources to carry out windows updates.

In order to deploy windows updates, terraform can be used to provision the resources needed for Packer to run in our AWS account

```
# Clone bash-tools 
git clone https://bitbucket.org/getbusyhq/bash-tools.git /<PATH-TO-LOCAL-BASH-TOOLS-REPO>/bash-tools
git clone https://bitbucket.org/getbusyhq/terraform-packer-tools.git /<PATH-TO-LOCAL-TERRAFORM-PACKER-TOOLS-REPO>/terraform-packer-tools

# Create a symlink of tflib.sh in local /usr/local/lib 
ln -s /usr/local/lib/tflib.sh /<PATH-TO-LOCAL-BASH-TOOLS-REPO>/bash-tools/usr/local/lib/tflib.sh

# Prepare to run tfplan & tfprovision to provision resources 
cd /<PATH-TO-LOCAL-TERRAFORM-PACKER-TOOLS-REPO>/terraform-packer-tools
rm -f terraform/.terraform/terraform.tfstate (if file already exists)

# Plan & Provivion (Perform the following steps from inside the cloned repo directory - terraform-packer-tools)
-- Plan -- 
/<PATH-TO-LOCAL-BASH-TOOLS-REPO>/bash-tools/usr/local/bin/tfplan.sh \
-r us-east-2 \
-p prd \
-m /<PATH-TO-LOCAL-JENKINS-REPO>/jenkins/terraform/terraform-provision-packer/smartvault/staging/backend/us-east-2.tfvars.json \
-c /<PATH-TO-LOCAL-JENKINS-REPO>/jenkins/terraform/terraform-provision-packer/smartvault/staging/tagging.tfvars.json \
-T /<PATH-TO-LOCAL-JENKINS-REPO>/jenkins/terraform/terraform-provision-packer/smartvault/staging/tagging.tfvars.json

-- Provision --
/Users/sv-fomenky/Documents/bitbucket/bash-tools/usr/local/bin/tfprovision.sh \
-r us-east-2 \
-p prd

```
PS: These tasks can be automated as a single job in jenkins using job DSL 

NOTE: Jenkins and Terraform is not restricted to only performing windows updates, it can be combined to deploy an entire infrastructure as code using Jenkinsfile and tf files.

### Structure
```
└── terraform
    └── terraform-provision-packer
        └── smartvault
            ├── dev
            │   └── terraform-provision-state.json
            ├── prod
            │   ├── backend
            │   │   └── us-east-2.tfvars.json
            │   ├── tagging.tfvars.json
            │   ├── terraform-provision-state.json
            │   └── terraform.tfvars.json
            ├── staging
            │   ├── backend
            │   │   └── us-east-2.tfvars.json
            │   ├── tagging.tfvars.json
            │   ├── terraform-provision-state.json
            │   └── terraform.tfvars.json
            └── terraform-provision-state.yml
```
TO DO: Will be moving this to a separate repo (terraform-packer-tools)

## Pipelines

This is where the magic happens. 

With pipelines we can orchestrate long running tasks.
In contrast to freestyle jobs, pipelines enable you to define a complete lifecycle.
Best to store each Jenkinsfile pipeline script on a separate git repo


### Provisioning

To start, Click New Item on the Jenkins home page > enter a name for the (pipeline) job > select Pipeline > click OK

Configure pipeline (EX: windows-update-pipeline):
```
- Definition: Pipeline script from SCM
    - SCM: 
        - Git
            - Repository url: git@bitbucket.org:getbusyhq/sv-packer-base-windows.git
            - Branches to build: */master

    - Script Path: Jenkinsfile
```

## Jobs (Freestyle Projects)

NOTE: For now no freestyle jobs have been created but as you can see, there's a few run-only-once tasks which can easily utilize this feature in the future.

### Structure
```
├── jobs
│   └── SampleJobDSL
```

# Extras
## Needed Plugins
```
- Blue Ocean
```

## Credentials
Add needed credentials to access teamcity from jenkins 
```
- bitbucketcreds
- jenkins-teamcity-access
```