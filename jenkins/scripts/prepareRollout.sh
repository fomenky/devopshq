#!/bin/bash

while getopts u:p:i:e:r: arg; do
    case $arg in
      u) TCUSERNAME=${OPTARG} ;;
      p) TCPASSWORD=${OPTARG} ;;
      i) TCIPADDRESS=${OPTARG} ;;
      e) EnvId=${OPTARG} ;;
      r) Region=${OPTARG} ;;
      *) echo "Usage: ..." ;;
    esac
done

# Get Golden AMI Ids from build output
appami=$(tail -n 2 $WORKSPACE/app-output.log | cut -d ' ' -f 2)
webami=$(tail -n 2 $WORKSPACE/web-output.log | cut -d ' ' -f 2)
postami=$(tail -n 2 $WORKSPACE/post-output.log | cut -d ' ' -f 2)

if [[ $appami == *"ami"* ]]; then
  appbuildnumber=$(aws dynamodb scan --profile $EnvId --region $Region --table-name smartvault-ddb-table-deploy --filter-expression "ZoneInc = :z AND Service = :s AND IsLatest = :il" --expression-attribute-values '{":z":{"S": "zone000"}, ":s":{"S": "appserver"}, ":il":{"S": "TRUE"}}' | grep -A 1 'Version' | cut -d '"' -f 4 | xargs)
  echo -e "ImageId (App) Found"
  echo $appami
else
  echo -e "Builds finished but no artifacts were created for App. See logs for details"
  appami=''
fi

if [[ $webami == *"ami"* ]]; then
  webbuildnumber=$(aws dynamodb scan --profile $EnvId --region $Region --table-name smartvault-ddb-table-deploy --filter-expression "ZoneInc = :z AND Service = :s AND IsLatest = :il" --expression-attribute-values '{":z":{"S": "zone000"}, ":s":{"S": "webserver"}, ":il":{"S": "TRUE"}}' | grep -A 1 'Version' | cut -d '"' -f 4 | xargs)
  echo -e "ImageId (Web) Found"
  echo $webami
else 
  echo -e "Builds finished but no artifacts were created for Web. See logs for details"
  webami=''
fi

if [[ $postami == *"ami"* ]]; then
  echo -e "ImageId (PostProc) Found"
  echo $postami
else
  echo -e "Builds finished but no artifacts were created for PostProc. See logs for details";
  postami=''
fi

# Trigger Prepare Rollout For All Zones
curl -v -u $TCUSERNAME:$TCPASSWORD http://$TCIPADDRESS/app/rest/buildQueue --header "Content-Type: application/xml" --data-binary \
"<build personal='true' branchName='SPR-3041-initiate-ami-windows-updates-from-jenkins'> <buildType id='SmartVault_Buildv3_RunRolloutExe'/> <comment><text>Triggered by Jenkins</text></comment> <properties><property name='AppAmi' value='$appami'/><property name='WebAmi' value='$webami'/><property name='PostAmi' value='$postami'/><property name='AppBuildNumber' value='$appbuildnumber'/><property name='WebBuildNumber' value='$webbuildnumber'/></properties> </build>"


status=$?

if [[ $status == 0 ]] ; then
  
  # Wait for create rollout stacks to be triggered
  sleep 20s
	echo -e "Successfully Triggered TeamCity Build"

  for type in appserver webserver postprocserver; do
    stoploop='false'
    until [[ $stoploop == 'true' ]]; do
      aws cloudformation wait stack-create-complete --stack-name smartvault-$EnvId-rollout-$type --profile $EnvId --region $Region
      stackstatus=$(aws cloudformation describe-stacks --stack-name smartvault-$EnvId-rollout-$type  --query 'Stacks[].StackStatus' --output text --profile $EnvId --region $Region)
      if [[ $stackstatus == 'CREATE_COMPLETE' ]]; then
        echo "Successfully created $type rollout stack"
        stoploop='true'
      elif [[ $stackstatus == 'CREATE_FAILED' ]]; then
        echo "Failed to create $type rollout stack"
        stoploop='true'
        exit 1
      else 
        echo "Unknown Error. See Cloudformation logs for details"
        stoploop='true'
        exit 1
      fi
    done
  done

else
  echo -e "Failed to Trigger TeamCity Build. See logs for details"
	exit $status
fi


