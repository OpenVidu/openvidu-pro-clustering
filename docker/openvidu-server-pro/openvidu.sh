#!/bin/bash

usage() {
    printf "Usage: \n\t openvidu [command]"
    printf "\n\nAvailable Commands:"
    printf "\n\tstart\t\tStart all services"
    printf "\n\tstop\t\tStop all services"
    printf "\n\trestart\t\tRestart all stoped and running services"
    printf "\n\tlogs\t\tShow openvidu-server logs"
    printf "\n\thelp\t\tShow help for openvidu command"
    printf "\n"
}

case $1 in

  start)
    docker-compose up -d
    docker-compose logs -f openvidu-server
    ;;

  stop)
    docker-compose down
    ;;

  restart)
    docker-compose restart
    docker-compose logs -f openvidu-server
    ;;

  logs)
    docker-compose logs -f openvidu-server
    ;;

  *)
    usage
    ;;
esac
