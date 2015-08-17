#!/bin/bash
set -ex

DOCKER_GID="233"

apt-get update -qq
apt-get install -qqy apt-transport-https

## Docker repo
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

## EugridPMA repo
echo "deb http://repository.egi.eu/sw/production/cas/1/current egi-igtf core" > /etc/apt/sources.list.d/egi-cas.list
wget -q -O - https://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3 | apt-key add -

apt-get update -qq
apt-get install -y ca-policy-egi-core fetch-crl apparmor ca-certificates iptables docker-engine curl
apt-get clean
rm -rf /var/lib/apt/lists/*

## Change docker GID so that it plays nicely with coreos hypervisor
groupmod -g ${DOCKER_GID} docker

## Let jenkins run docker
usermod -a -G docker jenkins

## Install IGI test CA
curl https://raw.githubusercontent.com/andreaceccanti/test-ca/master/igi-test-ca/igi-test-ca.pem -o /usr/local/share/ca-certificates/igi-test-ca.crt

## Rehash certificates
update-ca-certificates

## Setup jenkins private key
mkdir /home/jenkins/.ssh
cp /authorized_keys /home/jenkins/.ssh
chown -R jenkins:jenkins /home/jenkins/.ssh
chmod 400 /home/jenkins/.ssh/authorized_keys
chmod 700 /home/jenkins/.ssh
