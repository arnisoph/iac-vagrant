#!/bin/bash

echo '##############################################'
echo "Starting ${0}.."
set -x

wget https://raw.githubusercontent.com/saltstack/salt-bootstrap/stable/bootstrap-salt.sh ; chmod +x bootstrap-salt.sh
./bootstrap-salt.sh -M -K -g https://github.com/bechtoldt/salt.git git 2014.7-arbe

cat << EOF > /etc/salt/minion
file_roots:
  base:
    - /srv/salt/states

pillar_roots:
  base:
    - /srv/salt/pillar

module_dirs:
  - /srv/salt/_modules

file_client: local
EOF

mkdir -p /srv/salt/{_grains,_modules,_states,contrib,pillar,states}

service salt-minion restart
