# Lobsters on OpenShift

WIP

[Lobsters](https://github.com/lobsters/lobsters/)

```
PROJECT=lobsters
oc -n openshift process mariadb-persistent -p MYSQL_DATABASE=lobsters | oc -n $PROJECT create -f -
oc -n $PROJECT apply -f openshift/job-db-initialize.yaml
oc process -f openshift/template.yaml | oc -n $PROJECT apply -f -
oc -n $PROJECT expose service lobsters
```

## Custom CSS

```
oc -n $PROJECT create configmap lobsters-custom --from-file custom.css
oc -n $PROJECT volume dc/lobsters --add --name=lobsters-custom -t configmap \
  -m /opt/lobsters/app/assets/stylesheets/local --configmap-name=lobsters-custom
```

## TODO

* OpenShift deployment
  * APB
* Proper README
* Backup


