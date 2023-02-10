# Official Jenkins Docker image

[![Docker Stars](https://img.shields.io/docker/stars/jenkins/jenkins.svg)](https://hub.docker.com/r/jenkins/jenkins/)
[![Docker Pulls](https://img.shields.io/docker/pulls/jenkins/jenkins.svg)](https://hub.docker.com/r/jenkins/jenkins/)
[![Join the chat at https://gitter.im/jenkinsci/docker](https://badges.gitter.im/jenkinsci/docker.svg)](https://gitter.im/jenkinsci/docker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The Jenkins Continuous Integration and Delivery server [available on Docker Hub](https://hub.docker.com/r/jenkins/jenkins).

This is a fully functional Jenkins server.
[https://jenkins.io/](https://jenkins.io/).

<img src="https://jenkins.io/sites/default/files/jenkins_logo.png"/>


# Usage

Build:
```
docker build -t smartvault.devops.jenkins -f /<PATH-TO-LOCAL-JENKINS-REPO>/jenkins/docker/Dockerfile .   

```
Tag: 
```
docker tag smartvault.devops.jenkins account-id.dkr.ecr.us-east-2.amazonaws.com/smartvault.devops.jenkins
```
Push: 
```
aws ecr get-login --region us-east-2 --no-include-email | sh ; docker push account-id.dkr.ecr.us-east-2.amazonaws.com/smartvault.devops.jenkins
```

NOTE: By default, the jenkins-master cloudformation template pulls the latest jenkins image on creation. 


# Updates
For updates or modifications, update the Dockerfile as needed then build, tag and push new image. 
After a successful push, pull new image from EC2 instance:
```
aws ecr get-login --region us-east-2 --no-include-email | sh ; docker pull 450560603497.dkr.ecr.us-east-2.amazonaws.com/smartvault.devops.jenkins:latest
```

Deploy new image from EC2 instance:
```
docker run -t -d -v /var/jenkins_home:/var/jenkins_home:z -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):$(which docker) -p 80:8080 --name jenkins-master --restart=always 450560603497.dkr.ecr.us-east-2.amazonaws.com/smartvault.devops.jenkins:latest
```