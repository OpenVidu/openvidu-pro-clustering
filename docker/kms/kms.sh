#!/bin/bash

usage() {
    printf "Usage: \n\t kms [command]"
    printf "\n\nAvailable Commands:"
    printf "\n\tstart\t\tStart kms service"
    printf "\n\tstop\t\tStop kms service"
    printf "\n\trestart\t\tRestart kms service"
    printf "\n\tlogs\t\tShow kms logs"
    printf "\n\thelp\t\tShow help for kms command"
    printf "\n"
}

case $1 in

  start)
    docker-compose up -d
    docker-compose logs -f kms
    ;;

  stop)
    docker-compose down
    ;;

  restart)
    docker-compose restart
    docker-compose logs -f kms
    ;;

  logs)
    docker-compose logs -f kms
    ;;

  *)
    usage
    ;;
esac
