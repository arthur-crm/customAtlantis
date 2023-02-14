#!/bin/dumb-init /bin/sh
set -e

# the script is being executed by the root user
ATLANTIS_HOME=/home/atlantis

# GITHUB_USER_SSH_KEY is set through the atlantis helm chart
# In the atlantis-helm-chart-non-secret-values.yaml file, we have
#
# environment:
#  GITHUB_USER_SSH_KEY: "/etc/github-user-ssh-key/service-account.json"
#
# The private SSH key is passed to the atlantis helm chart from 70-atlantis.tf,
# the Terraform file that has the "helm_release.atlantis" definition
#
#  set {
#    name = "serviceAccountSecrets.github-user-ssh-key"
#    value = "${base64encode(file(local.github_user_ssh_key_file_name))}"
#  }
#
if [ -n "$GITHUB_USER_SSH_KEY" ] \
  && [ -f "$GITHUB_USER_SSH_KEY" ]; then

  if [ ! -d "$ATLANTIS_HOME/.ssh" ]; then
    mkdir "$ATLANTIS_HOME/.ssh"
  fi

  if [ ! -f "$ATLANTIS_HOME/.ssh/id_rsa" ]; then
    cp "$GITHUB_USER_SSH_KEY" "$ATLANTIS_HOME/.ssh/id_rsa"

    chmod 600 "$ATLANTIS_HOME/.ssh/id_rsa"

    ssh-keyscan github.com >> "$ATLANTIS_HOME/.ssh/known_hosts"

    chown atlantis:atlantis "$ATLANTIS_HOME/.ssh/id_rsa"
    chown atlantis:atlantis "$ATLANTIS_HOME/.ssh/known_hosts"
  fi

fi
