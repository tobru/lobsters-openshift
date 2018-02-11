# Lobsters on OpenShift

This repository contains an OpenShift 3 template to easily deploy [Lobsters](https://github.com/lobsters/lobsters/) on OpenShift.
With this template it's possible to run your own Lobsters instance f.e. on [APPUiO](https://appuio.ch/).

[![Docker Automated build](https://img.shields.io/docker/automated/tobru/lobsters.svg)](https://hub.docker.com/r/tobru/lobsters/) [![Docker Automated build](https://img.shields.io/docker/build/tobru/lobsters.svg)](https://hub.docker.com/r/tobru/lobsters/)

## Installation

### 0 Create OpenShift project

Create an OpenShift project if not already provided by the service

```
PROJECT=lobsters
oc new-project $PROJECT
```

### 1 Deploy Database

```
oc -n openshift process mariadb-persistent -p MYSQL_DATABASE=lobsters | oc -n $PROJECT create -f -
```

### 2 Deploy Lobsters

First deploy the DB initialization job, then Lobsters itself.

```
oc -n $PROJECT apply -f https://raw.githubusercontent.com/tobru/lobsters-openshift/master/openshift/job-db-initialize.yaml
oc process -f https://raw.githubusercontent.com/tobru/lobsters-openshift/master/openshift/template.yaml | oc -n $PROJECT apply -f -
oc -n $PROJECT expose service lobsters
```

#### Template parameters

Execute the following command to get the available parameters:

```
oc process -f https://raw.githubusercontent.com/tobru/lobsters-openshift/master/openshift/template.yaml --parameters
```

### 3 Customize Lobsters

Customization can be done using ConfigMaps or by forking the Lobsters project
and adapt the build-time parameter `GITHUB_NAMESPACE` to point to the fork.
In the case of a fork you must update the DeploymentConfiguration to point to
your own build of a Lobsters Docker image.

#### Custom CSS using a ConfigMap

```
oc -n $PROJECT create configmap lobsters-custom --from-file custom.css
oc -n $PROJECT volume dc/lobsters --add --name=lobsters-custom -t configmap \
  -m /opt/lobsters/app/assets/stylesheets/local --configmap-name=lobsters-custom
```

#### Custom Views using a ConfigMap

```
oc -n $PROJECT create configmap lobsters-views --from-file about.html.erb
oc -n $PROJECT volume dc/lobsters --add --name=lobsters-views -t configmap \
  -m /opt/lobsters_views --configmap-name=lobsters-views
```

#### Tags

There is no admin interface, it must be done manually:

```
oc -n $PROJECT rsh dc/lobsters rails c
Tag.create(tag: "hello", description: "example tag", is_media: false)
```

Links:

* [#319](https://github.com/lobsters/lobsters/issues/319)
* [#416](https://github.com/lobsters/lobsters/pull/416)

It's also possible to fiddle around directly in the database:

```
oc rsh dc/mariadb
MYSQL_PWD="$MYSQL_PASSWORD" mysql -h 127.0.0.1 -u $MYSQL_USER -D $MYSQL_DATABASE
select * from tags;
delete from tags where id = 1;
insert into tags set tag = 'mytag';
exit
exit
```

#### CronJobs

There are some cronjobs availabe for sending mails or tweeting links:

```
oc -n $PROJECT apply -f https://raw.githubusercontent.com/tobru/lobsters-openshift/master/openshift/cronjob-mail.yaml
oc -n $PROJECT apply -f https://raw.githubusercontent.com/tobru/lobsters-openshift/master/openshift/cronjob-twitter.yaml
```

#### E-Mail sending

To send E-Mails, a mail sending service like [Mailgun](https://www.mailgun.com/) must be configured:

```
oc -n $PROJECT env dc/lobsters \
  SMTP_HOST=smtp.mailgun.org \
  SMTP_USERNAME=postmaster@mydomain.com \
  SMTP_PASSWORD=mypassword \
  SMTP_PORT=587 \
  SMTP_STARTTLS_AUTO=true
```

## Backup

### Database

You can use the provided DB dump `CronJob` template:

```
oc process -f https://raw.githubusercontent.com/tobru/lobsters-openshift/master/openshift/cronjob-mariadb-backup.yaml | oc -n $PROJECT apply -f -
```

This script dumps the DB to the same PV as the database stores it's data.
You must make sure that you copy these files away to a real backup location.

## Contributions

Very welcome!

1. Fork it (https://github.com/tobru/lobsters-openshift/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

