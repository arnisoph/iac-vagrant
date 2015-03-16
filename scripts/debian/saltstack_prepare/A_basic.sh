#!/bin/bash
#TODO update config with /vagrant/share/fooo (master & minion config) + pillar, etc.
#TODO move dir creation to this file instead of saltstack_setup

echo '##############################################'
echo "Starting ${0}.."
set -x

minion_config_path=/vagrant/share/salt-config/${HOSTNAME}/config/minion
master_config_path=/vagrant/share/salt-config/${HOSTNAME}/config/master
states_top_path=/vagrant/share/salt-config/${HOSTNAME}/file_roots/states/top.sls
pillar_root=/vagrant/share/salt-config/${HOSTNAME}/file_roots/pillar/

mkdir -p /srv/salt/{_grains,_modules/formulas,_states,contrib/states,pillar/examples,states}

[[ -f $states_top_path ]] && ln -sf $states_top_path /srv/salt/states/top.sls
[[ -d $pillar_root && ! -e /srv/salt/pillar/share ]] && ln -sf $pillar_root /srv/salt/pillar/share
[[ -f $minion_config_path ]] && cp $minion_config_path /etc/salt/
[[ -f $master_config_path ]] && cp $master_config_path /etc/salt/

if [[ -d /vagrant/salt/formulas/ ]]; then
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

    src=${d}/_modules
    dst=/srv/salt/_modules/formulas/${f##*/}
    if [[ -d $src ]]; then
      find $d -type f -name '*.py' -exec ln -sf {} $dst \; || exit 1
    fi
  done
fi

if [[ -d /vagrant/salt/_modules/ ]]; then
  src=/vagrant/salt/_modules/
  dst=/srv/salt/_modules/common
  if [[ -e $src && ! -e $dst ]]; then ln -s $src $dst || exit 1; fi
fi
