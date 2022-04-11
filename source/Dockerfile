FROM ubuntu:focal-20220404

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y software-properties-common curl \
  apt-transport-https apt-utils lsb-release gnupg ca-certificates

RUN (curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -) && \
  (curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -) && \
  (curl -fsSL https://baltocdn.com/helm/signing.asc | apt-key add -) && \
  (curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -) && \
  (curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -) && \
  (curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | apt-key add -)
RUN apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://cli.github.com/packages stable main" && \
  apt-add-repository --yes --update ppa:ansible/ansible && \
  apt-add-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" && \
  apt-add-repository "deb https://baltocdn.com/helm/stable/debian/ all main" && \
  curl -fsSL -o pkg.deb https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb && \
  apt install -y ./pkg.deb && \
  rm -f pkg.deb

RUN apt update && apt install -y vim ansible git nmap dotnet-sdk-5.0 azure-functions-core-tools-3 npm \
  jq dotnet-sdk-3.1 aspnetcore-runtime-5.0 docker-ce docker-ce-cli containerd.io powershell \
  screen net-tools sshpass wireshark whois traceroute nuget tmux gh terraform azure-cli \
  kubectl=1.21.\* kubeadm=1.21.\* helm

ENTRYPOINT [ "/bin/bash" ]
