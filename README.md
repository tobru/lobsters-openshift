# Lobsters on OpenShift

WIP

[Lobsters](https://github.com/lobsters/lobsters/)

docker-compose exec lobsters rake db:schema:load
docker-compose exec lobsters rake db:seed
docker-compose run lobsters rake secret
