#!/bin/sh

kubectl delete deployment,service -l app=drupal
kubectl delete secret mysql
kubectl delete pvc -l app=drupal
kubectl delete pv mysql-volume drupal-volume
