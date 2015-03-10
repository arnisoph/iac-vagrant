#!/bin/bash

echo '##############################################'
echo "Starting ${0}.."
set -x

for d in /vagrant/salt/formulas/*; do
  src=${d}/states
  dst=/srv/salt/states/${d##*/}
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi

  src=${d}/contrib/states
  dst=/srv/salt/contrib/states/${d##*/}
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi

  src=${d}/pillar_examples
  dst=/srv/salt/pillar/${d##*/}
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi
done

find /vagrant/salt/formulas/ -path '*/_modules/*' -type f -name '*.py' -exec cp {} /srv/salt/_modules/ \; || exit 1
if [[ -d /vagrant/salt/_modules/ ]]; then find /vagrant/salt/_modules/ -type f -name '*.py' -exec cp {} /srv/salt/_modules/ \; || exit 1; fi
