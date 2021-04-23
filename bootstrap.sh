#!/bin/bash
set -eo pipefail

readonly USERNAME=${1}
readonly RHN_PASSWORD=${2}
readonly POOL_ID=${POOL_ID:-'8a85f98260c27fc50160c323247e39e0'}
readonly REPO_TO_ENABLE=${REPO_TO_ENABLE:-'ansible-2.9-for-rhel-8-x86_64-rpms'}
readonly NETWORK_TEST_IP=${NETWORK_TEST_IP:-'10.36.110.1'}
readonly ANSIBLE_GIT_URL=${ANSIBLE_GIT_URL:-'https://rpelisse@github.com/jboss-set/zeus.git'}
readonly ANSIBLE_GIT_BRANCH=${ANSIBLE_GIT_BRANCH:-'olympus'}
readonly ANSIBLE_VARS_GIT_URL=${3}
readonly ANSIBLE_MAIN_SCRIPT=${4:-'zeus.yml'}

set -u

if [ -z "${USERNAME}" ]; then
  echo "No RHN username provided - aborting"
  exit 1
fi

if [ -z "${RHN_PASSWORD}" ]; then
  echo "No RHN PASSWORD provided - aborting"
  exit 2
fi

checkIfWithinAppropriateNetwork() {
  local test_ip=${1}
  echo "Abort if not within Red Hat Network..."
  ping -c 5 "${test_ip}"
}

registrationAndSubs() {
  local username=${1}
  local password=${2}
  local pool_id=${3}
  local repo_to_enable=${4}

  subscription-manager register --username="${username}" --password="${password}"
  subscription-manager refresh
  subscription-manager attach --auto
  subscription-manager attach --pool="${pool_id}"
  subscription-manager repos --enable "${repo_to_enable}"
}

updateAndInstallReqs() {
  cat /etc/redhat-release
  yum update -y
  cat /etc/redhat-release
  yum install -y git ansible
  ansible-playbook --version
  git --version
}

setupAnsible() {
  mv /etc/ansible/ /etc/ansible.bck
  git clone "${ANSIBLE_GIT_URL}" /etc/ansible/
  cd /etc/ansible/
  git checkout "origin/${ANSIBLE_GIT_BRANCH}" -b "${ANSIBLE_GIT_BRANCH}"
}

setupAnsibleVars() {
  checkIfWithinAppropriateNetwork "${NETWORK_TEST_IP}"
  git config --global http.sslVerify false
  git clone "${ANSIBLE_VARS_GIT_URL}" vars
  git checkout "origin/${ANSIBLE_GIT_BRANCH}" -b "${ANSIBLE_GIT_BRANCH}"
}

fixupUserUsingJenkinsUID() {
  local uid='1000'
  local guid='1000'
  local uid_file=/etc/passwd

  set -e
  res=$(grep -e "${uid}" ${uid_file} | wc -l)
  if [ "${res}" -eq 1 ]; then
    username=$(echo "${res}" | cut -f1 -d: )
    echo "user ${username} already uses UID ${uid}. Kill all tied process before uid change..."
    pids=$(ps -eF | grep "^${username}" | sed -e "s/^${username} *//" | cut -f1 -d\  )
    kill ${pids}
    kill -9 ${pids}
    set +e
    usermod -u 3000 "${username}"
    groupmod -g 3000 "${username}"
  fi
  
}

registrationAndSubs "${USERNAME}" "${RHN_PASSWORD}" "${POOL_ID}" "${REPO_TO_ENABLE}"
updateAndInstallReqs
setupAnsible
setupAnsibleVars
fixupUserUsingJenkinsUID
setenforce 0
ansible-playbook "${ANSIBLE_MAIN_SCRIPT}"
