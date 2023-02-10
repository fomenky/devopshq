#!/usr/bin/env bash

################################################################################
#
# tflib.sh - utility functions and commands for handling Terraform tools.
#
################################################################################
#
# Contributors:
# [DB]  Daniele Borsaro daniele.borsaro@getbusy.com
#
# Changelog:
#   2019-07-24  0.1.0   Initial version

if (( !tflib_IS_INCLUDED )); then

tflib_IS_INCLUDED=1

set +e
set -u


declare -i -r tflib_STATUS_OK=0
declare -i -r tflib_STATUS_PARAM=1
declare -i -r tflib_STATUS_TERRAFORM_ERROR=2
declare -i -r tflib_STATUS_UNDEFINED=255

declare -i -r tflib_TRUE=1
declare -i -r tflib_FALSE=0

declare -r tflib_DEFAULT_AWS_PROFILE="${AWS_PROFILE:-default}"
declare -r tflib_DEFAULT_TERRAFORM_WORKSPACE="default"
declare -r tflib_DEFAULT_BASE_DIR="$( pwd )"

declare -r tflib_DEFAULT_TERRAFORM_PLANFILE="./terraform.tfplan"

declare -i tflib_isPushed=$tflib_FALSE
declare -i tflib_commandResult=$tflib_STATUS_OK

declare -i -r tflib_ACTION_CODE_PLAN=0
declare -i -r tflib_ACTION_CODE_PROVISION=1
declare -i -r tflib_ACTION_CODE_DESTROY=2

declare -r tflib_USAGE_PLAN="
    Plans Terraform provisioning.

    Usage:
    ~$ [DEBUG=<0|1>] [TRACE=<0|1>] ${0} [-p <aws-profile>] -r <aws-region> [-w <terraform-workspace>] [-t <terraform-code-dir>] [-m <manifest-file>] [-c <config-file>] [-T <tagging-file>]

    Arguments:
        -p  AWS profile as configured in the AWS CLI auth helper
        -r  AWS target region
        -w  Terraform workspace
        -t  Terraform source code
        -m  Terraform backend file
        -c  Terraform configuration file

    Options:
        DEBUG   enables debug output
        TRACE   enables detailed execution logging
    "

declare -r tflib_USAGE_PROVISION="
    Executes Terraform provisioning.

    Usage:
    ~$ [DEBUG=<0|1>] [TRACE=<0|1>] ${0} [-p <aws-profile>] -r <aws-region> [-w <terraform-workspace>] [-t <terraform-code-dir>]

    Arguments:
        -p  AWS profile as configured in the AWS CLI auth helper
        -r  AWS target region
        -w  Terraform workspace
        -t  Terraform source code

    Options:
        DEBUG   enables debug output
        TRACE   enables detailed execution logging
    "

declare -r tflib_USAGE_DESTROY="
    Executes Terraform destroy.

    Usage:
    ~$ [DEBUG=<0|1>] [TRACE=<0|1>] ${0} [-p <aws-profile>] -r <aws-region> [-w <terraform-workspace>] [-t <terraform-code-dir>] [-m <manifest-file>] [-c <config-file>] [-T <tagging-file>] [-A]

    Arguments:
        -p  AWS profile as configured in the AWS CLI auth helper
        -r  AWS target region
        -w  Terraform workspace
        -t  Terraform source code
        -m  Manifest file
        -c  Terraform configuration file
        -A  Auto approve, do not ask for confirmation

    Options:
        DEBUG   enables debug output
        TRACE   enables detailed execution logging
    "


## Functions
function tflib_Usage() {
  local -i -r param_actionCode="${1:-$tflib_ACTION_CODE_PLAN}"

  case $param_actionCode in
    $tflib_ACTION_CODE_PLAN)
      echo -e "${tflib_USAGE_PLAN}"
      ;;

    $tflib_ACTION_CODE_PROVISION)
      echo -e "${tflib_USAGE_PROVISION}"
      ;;

    $tflib_ACTION_CODE_DESTROY)
      echo -e "${tflib_USAGE_DESTROY}"
      ;;

    *)
      tflib_Fail "Unexpected action code $param_actionCode"
      ;;
  esac


  return $tflib_STATUS_OK
} ## end function tflib_Usage()


function tflib_Fail() {
  local -r param_message="${1:-}"
  local -i -r param_status="${2:-$tflib_STATUS_UNDEFINED}"

  echo -e "${param_message}"

  (( tflib_isPushed )) && popd

  exit $param_status
} ## end function tflib_Fail()


function tflib_Plan() {

  local -i -r tflib_isDebug="${DEBUG:-0}"
  local -i -r tflib_isTrace="${TRACE:-0}"

  (( tflib_isTrace )) && set -o xtrace

  local param_awsHelperProfile="${tflib_DEFAULT_AWS_PROFILE}"
  local param_awsTargetRegion=""
  local param_tfWorkspaceName="${tflib_DEFAULT_TERRAFORM_WORKSPACE}"
  local param_tfCodeDir="${tflib_DEFAULT_BASE_DIR}/terraform"
  local param_tfBackendFile=""
  local param_tfConfigFile=""

  while getopts "p:r:w:t:m:c:h" arg; do
    case "${arg}" in
      p)
          param_awsHelperProfile=${OPTARG}
          ;;

      r)
          param_awsTargetRegion=${OPTARG}
          ;;

      w)
          param_tfWorkspaceName=${OPTARG}
          ;;

      t)
          param_tfCodeDir=${OPTARG}
          ;;

      m)
          param_tfBackendFile=${OPTARG}
          ;;

      c)
          param_tfConfigFile=${OPTARG}
          ;;

      *)
          tflib_Usage $tflib_ACTION_CODE_PLAN
          return $tflib_STATUS_PARAM
          ;;
    esac
  done
  shift $((OPTIND-1))

  [[ ! -n "${param_awsTargetRegion}" ]]  &&  tflib_Fail "AWS region not specified"
  [[ ! -n "${param_tfBackendFile}" ]]  &&  tflib_Fail "Backend file not specified"
  [[ ! -n "${param_tfConfigFile}" ]]  &&  tflib_Fail "Config file not specified"
  [[ ! -d "${param_tfCodeDir}" ]]  &&  tflib_Fail "Code directory does not exist"

  echo -e "AWS profile:  '${param_awsHelperProfile}'"
  echo -e "AWS region:   '${param_awsTargetRegion}'"
  echo -e "TF workspace: '${param_tfWorkspaceName}'"
  echo -e "TF code:      '${param_tfCodeDir}'"
  echo -e "Manifest:     '${param_tfBackendFile}'"
  echo -e "Config:       '${param_tfConfigFile}'"

  pushd "${param_tfCodeDir}" && tflib_isPushed=$tflib_TRUE

  echo -e "Terraform init..."
  AWS_PROFILE="${param_awsHelperProfile}" AWS_REGION="${param_awsTargetRegion}" terraform init -get=true -upgrade=true -backend-config="${param_tfBackendFile}" || tflib_Fail "Unable to init backend"

  echo -e "Terraform workspace..."
  tflib_commandResult=$tflib_STATUS_OK
  set +e
  AWS_PROFILE="${param_awsHelperProfile}" terraform workspace new "${param_tfWorkspaceName}"
  tflib_commandResult=$?
  set -e
  if (( tflib_commandResult )); then
    echo -e "Selecting existing workspace..."
    AWS_PROFILE="${param_awsHelperProfile}" terraform workspace select "${param_tfWorkspaceName}" || tflib_Fail "Unable to create workspace"
  fi

  echo -e "Terraform validate..."
  time AWS_PROFILE="${param_awsHelperProfile}" AWS_REGION="${param_awsTargetRegion}" terraform validate || tflib_Fail "Unable to validate"

  echo -e "Terraform plan..."
  time AWS_PROFILE="${param_awsHelperProfile}" AWS_REGION="${param_awsTargetRegion}" terraform plan -var-file="${param_tfConfigFile}" -var="aws_region=${param_awsTargetRegion}" -out "${tflib_DEFAULT_TERRAFORM_PLANFILE}" || tflib_Fail "Unable to plan"

  popd

  return $?
} ## end function tflib_Plan()


function tflib_Provision() {

  local -i -r tflib_isDebug="${DEBUG:-0}"
  local -i -r tflib_isTrace="${TRACE:-0}"

  (( tflib_isTrace )) && set -o xtrace

  local param_awsHelperProfile="${tflib_DEFAULT_AWS_PROFILE}"
  local param_awsTargetRegion=""
  local param_tfWorkspaceName="${tflib_DEFAULT_TERRAFORM_WORKSPACE}"
  local param_tfCodeDir="${tflib_DEFAULT_BASE_DIR}/terraform"

  while getopts "p:r:w:t:h" arg; do
    case "${arg}" in
      p)
          param_awsHelperProfile=${OPTARG}
          ;;

      r)
          param_awsTargetRegion=${OPTARG}
          ;;

      w)
          param_tfWorkspaceName=${OPTARG}
          ;;

      t)
          param_tfCodeDir=${OPTARG}
          ;;

      *)
          tflib_Usage $tflib_ACTION_CODE_PROVISION
          return $tflib_STATUS_PARAM
          ;;
    esac
  done
  shift $((OPTIND-1))

  [[ ! -n "${param_awsTargetRegion}" ]]  &&  tflib_Fail "AWS region not specified"
  [[ ! -d "${param_tfCodeDir}" ]]  &&  tflib_Fail "Code directory does not exist"

  echo -e "AWS profile:  '${param_awsHelperProfile}'"
  echo -e "AWS region:   '${param_awsTargetRegion}'"
  echo -e "TF workspace: '${param_tfWorkspaceName}'"
  echo -e "TF code:      '${param_tfCodeDir}'"

  pushd "${param_tfCodeDir}" && tflib_isPushed=$tflib_TRUE

  echo -e "Terraform apply..."
  time AWS_PROFILE="${param_awsHelperProfile}" AWS_REGION="${param_awsTargetRegion}" terraform apply "${tflib_DEFAULT_TERRAFORM_PLANFILE}" || tflib_Fail "Unable to publish statefile"

  popd

  return $?
} ## end function tflib_Provision()


function tflib_Destroy() {

  local -i -r tflib_isDebug="${DEBUG:-0}"
  local -i -r tflib_isTrace="${TRACE:-0}"

  (( tflib_isTrace )) && set -o xtrace

  local tf_opts=""

  local param_awsHelperProfile="${tflib_DEFAULT_AWS_PROFILE}"
  local param_awsTargetRegion=""
  local param_tfWorkspaceName="${tflib_DEFAULT_TERRAFORM_WORKSPACE}"
  local param_tfCodeDir="${tflib_DEFAULT_BASE_DIR}/terraform"
  local param_tfBackendFile="../../../VirtualCabinetPortal/vcp-vc-config/dev/backend.tfvars.json"
  local param_tfConfigDir="../../../VirtualCabinetPortal/vcp-vc-config/dev/terraform.tfvars.json"
  local param_tfAutoApprove=""

  while getopts "p:r:w:t:m:c:A" arg; do
    case "${arg}" in
      p)
          param_awsHelperProfile=${OPTARG}
          ;;

      r)
          param_awsTargetRegion=${OPTARG}
          ;;

      w)
          param_tfWorkspaceName=${OPTARG}
          ;;

      t)
          param_tfCodeDir=${OPTARG}
          ;;

      m)
          param_tfBackendFile=${OPTARG}
          ;;

      c)
          param_tfConfigDir=${OPTARG}
          ;;

      A)
        param_tfAutoApprove="-auto-approve"
      ;;

      *)
          tflib_Usage $tflib_ACTION_CODE_DESTROY
          return $tflib_STATUS_PARAM
          ;;
    esac
  done
  shift $((OPTIND-1))

  [[ ! -n "${param_awsTargetRegion}" ]]  &&  tflib_Fail "AWS region not specified"
  [[ ! -d "${param_tfCodeDir}" ]]  &&  tflib_Fail "Code directory does not exist"

  echo -e "AWS profile:  '${param_awsHelperProfile}'"
  echo -e "AWS region:   '${param_awsTargetRegion}'"
  echo -e "TF workspace: '${param_tfWorkspaceName}'"
  echo -e "TF code:      '${param_tfCodeDir}'"
  echo -e "Manifest:     '${param_tfBackendFile}'"
  echo -e "Config:       '${param_tfConfigDir}'"
  echo -e "Auto-approve: '${param_tfAutoApprove}'"

  tf_opts="${tf_opts} ${param_tfAutoApprove}"

  pushd "${param_tfCodeDir}" && tflib_isPushed=$tflib_TRUE

  echo -e "Terraform workspace..."
  tflib_commandResult=$tflib_STATUS_OK
  set +e
  AWS_PROFILE="${param_awsHelperProfile}" terraform workspace new "${param_tfWorkspaceName}"
  tflib_commandResult=$?
  set -e
  if (( tflib_commandResult )); then
    echo -e "Selecting existing workspace..."
    AWS_PROFILE="${param_awsHelperProfile}" terraform workspace select "${param_tfWorkspaceName}" || tflib_Fail "Unable to create workspace"
  fi

  echo -e "Terraform init..."
  AWS_PROFILE="${param_awsHelperProfile}" AWS_REGION="${param_awsTargetRegion}" terraform init -get=true -upgrade -backend-config="${param_tfBackendFile}" || tflib_Fail "Unable to init backend"

  time AWS_PROFILE="${param_awsHelperProfile}" AWS_REGION="${param_awsTargetRegion}" terraform destroy ${tf_opts} -var-file="${param_tfConfigDir}" -var="aws_region=${param_awsTargetRegion}" || tflib_Fail "Unable to publish statefile"

  popd

  return $?
} ## end function tflib_Destroy()

## NB: https://github.com/scop/bash-completion/issues/44
set +u

fi ## end check $tflib_IS_INCLUDED
