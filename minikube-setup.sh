#!/bin/bash -e

setup_minikube() {
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Download minikube
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube-linux-amd64
    sudo mv minikube-linux-amd64 /usr/local/bin/minikube

    # Start minikube
    export CHANGE_MINIKUBE_NONE_USER=true
    sudo -E minikube start
}

main(){
    if ! setup_minikube; then
        test_failed "$0"
    else
        test_passed "$0"
    fi
}

main