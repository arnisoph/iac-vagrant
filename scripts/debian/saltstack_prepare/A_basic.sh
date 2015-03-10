#!/bin/bash
#TODO update config with /vagrant/share/fooo (master & minion config) + pillar, etc.
#TODO move dir creation to this file instead of saltstack_setup

echo '##############################################'
echo "Starting ${0}.."
set -x

minion_config_path=/vagrant/share/salt-config/${HOSTNAME}/config/minion
master_config_path=/vagrant/share/salt-config/${HOSTNAME}/config/master
states_top_path=/vagrant/share/salt-config/${HOSTNAME}/file_roots/states/top.sls
pillar_top_path=/vagrant/share/salt-config/${HOSTNAME}/file_roots/pillar/top.sls
mkdir -p /srv/salt/states/
mkdir -p /srv/salt/contrib/states/
mkdir -p /srv/salt/pillar/examples/

[[ -f $states_top_path ]] && cp $states_top_path /srv/salt/states/
[[ -f $pillar_top_path ]] && cp $pillar_top_path /srv/salt/pillar/
[[ -f $minion_config_path ]] && cp $minion_config_path /etc/salt/
[[ -f $master_config_path ]] && cp $master_config_path /etc/salt/

for d in /vagrant/salt/formulas/*; do
  if [[ -d ${d}/states ]]; then
    src=${d}/states
    dst=/srv/salt/states/${d##*/}
  else
    src=${d}/${d##*/}
    dst=/srv/salt/states/${d##*/}
  fi
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi

  if [[ -d ${d}/contrib/states ]]; then
    src=${d}/contrib/states
    dst=/srv/salt/contrib/states/${d##*/}
  fi
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi

  src=${d}/pillar_examples
  dst=/srv/salt/pillar/examples/${d##*/}
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi
done

find /vagrant/salt/formulas/ -path '*/_modules/*' -not -path '*/.git/*' -type f -name '*.py' -print -exec cp {} /srv/salt/_modules/ \; || exit 1 #TODO move to loop
if [[ -d /vagrant/salt/_modules/ ]]; then find /vagrant/salt/_modules/ -type f -name '*.py' -exec cp {} /srv/salt/_modules/ \; || exit 1; fi
