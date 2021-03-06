#!/bin/bash
. ~/.bashrc
GITSHA=$(git rev-parse --short HEAD)

case "$1" in
    container)
        sudo -u koji docker build -t auditservice:$GITSHA .
        sudo -u koji docker tag auditservice:$GITSHA \
             kjmatsuda/auditservice:$GITSHA
        sudo -i -u koji docker push \
             kjmatsuda/auditservice:$GITSHA
    ;;
    deploy)
        sed -e s/_NAME_/auditservice/ -e s/_PORT_/8081/ \
            < ../deployment/service-template.yml > svc.yml
        sed -e s/_NAME_/auditservice/ -e s/_PORT_/8081/ \
            -e s/_IMAGE_/kjmatsuda\\/auditservice:$GITSHA/ \
            < ../deployment/deployment-template.yml > dep.yml
        sudo -i -u koji kubectl apply -f $(pwd)/svc.yml --validate=false
        sudo -i -u koji kubectl apply -f $(pwd)/dep.yml --validate=false
    ;;
    *)
        echo invalid build step
        exit 1
    ;;
esac
