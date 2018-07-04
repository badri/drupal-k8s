#!/bin/sh

# Create secret for WordPress
kubectl create secret generic mysql --from-literal=password=mysql123

# Create MySQL deployment
kubectl create -f ./mysql-deployment.yml

# Drupal deployment
kubectl create -f ./drupal-deployment.yml
