#!/bin/bash
source ~/.bashrc
GITSHA=$(git rev-parse --short HEAD)

case "$1" in
    container)
        sudo -u koji docker build -t addservice:$GITSHA .
        sudo -u koji docker tag addservice:$GITSHA \
             kjmatsuda/addservice:$GITSHA
        sudo -i -u koji docker push \
             kjmatsuda/addservice:$GITSHA
    ;;
    deploy)
        sed -e s/_NAME_/addservice/ -e s/_PORT_/8080/ \
            < ../deployment/service-template.yml > svc.yml
        sed -e s/_NAME_/addservice/ -e s/_PORT_/8080/ \
            -e s/_IMAGE_/kjmatsuda\\/addservice:$GITSHA/ \
            < ../deployment/deployment-template.yml > dep.yml
        sudo -i -u kjmatsuda kubectl apply -f $(pwd)/svc.yml
        sudo -i -u kjmatsuda kubectl apply -f $(pwd)/dep.yml
    ;;
    *)
        echo invalid build step
        exit 1
    ;;
esac
