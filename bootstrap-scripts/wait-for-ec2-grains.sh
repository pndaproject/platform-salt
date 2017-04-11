#!/bin/bash -v
echo 'Checking ec2 grains are present on all minions...'
GRAIN_RETRIES=0
until [[ $(sudo salt "*" grains.get ec2 | grep region | wc -l) -eq $(sudo salt "*" grains.get pnda | grep flavor | wc -l) ]] || [[ $GRAIN_RETRIES -eq "180" ]]; do
  sleep 1
  echo waiting for ec2 grains, retry $(( GRAIN_RETRIES++ )) of 180
done
