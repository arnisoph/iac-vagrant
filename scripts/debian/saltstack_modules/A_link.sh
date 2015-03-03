#!/bin/bash

echo '##############################################'
echo "Starting ${0}.."
set -x

for d in /vagrant/salt/formulas/*; do
  src=${d}/states
  dst=/srv/salt/states/${d##*/}
  [[ ! -e $dst ]] && ln -s $src $dst
done

find /vagrant/salt/formulas/ -path '*/_modules/*' -type f -name '*.py' -exec cp {} /srv/salt/_modules/ \;
[[ -d /vagrant/salt/_modules/ ]] && find /vagrant/salt/_modules/ -type f -name '*.py' -exec cp {} /srv/salt/_modules/ \;
