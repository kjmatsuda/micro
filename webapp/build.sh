#!/bin/bash
. ~/.bashrc
GITSHA=$(git rev-parse --short HEAD)

case "$1" in
    container)
        sudo -u koji docker build -t webapp:$GITSHA .
        sudo -u koji docker tag webapp:$GITSHA \
             kjmatsuda/webapp:$GITSHA
        sudo -i -u koji docker push \
             kjmatsuda/webapp:$GITSHA
    ;;
    deploy)
        sed -e s/_NAME_/webapp/ -e s/_PORT_/3000/ \
            < ../deployment/service-template.yml > svc.yml
        sed -e s/_NAME_/webapp/ -e s/_PORT_/3000/ \
            -e s/_IMAGE_/kjmatsuda\\/webapp:$GITSHA/ \
            < ../deployment/deployment-template.yml > dep.yml
        sudo -i -u koji kubectl apply -f $(pwd)/svc.yml --validate=false
        sudo -i -u koji kubectl apply -f $(pwd)/dep.yml --validate=false
    ;;
    *)
        echo invalid build step
        exit 1
    ;;
esac
