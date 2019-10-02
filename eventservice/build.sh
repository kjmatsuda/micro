#!/bin/bash
. ~/.bashrc
GITSHA=$(git rev-parse --short HEAD)

case "$1" in
    container)
        sudo -u koji docker build -t eventservice:$GITSHA .
        sudo -u koji docker tag eventservice:$GITSHA \
             kjmatsuda/eventservice:$GITSHA
        sudo -i -u koji docker push \
             kjmatsuda/eventservice:$GITSHA
    ;;
    deploy)
        sed -e s/_NAME_/eventservice/ -e s/_PORT_/8082/ \
            < ../deployment/service-template.yml > svc.yml
        sed -e s/_NAME_/eventservice/ -e s/_PORT_/8082/ \
            -e s/_IMAGE_/kjmatsuda\\/eventservice:$GITSHA/ \
            < ../deployment/deployment-template.yml > dep.yml
        sudo -i -u koji kubectl apply -f $(pwd)/svc.yml --validate=false
        sudo -i -u koji kubectl apply -f $(pwd)/dep.yml --validate=false
    ;;
    *)
        echo invalid build step
        exit 1
    ;;
esac
