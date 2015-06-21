# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Useful vagrant plugins:
#
# * vagrant-notify
# * vagrant-cachier
# * vagrant-vbguest
#
require 'yaml'

def get(key, global, node)
  node[key] || global['defaults'][key] || nil
end

Vagrant.require_version '>= 1.6.5'

Vagrant.configure('2') do |cfg|
  nodes_yaml_path = File.dirname(__FILE__) + '/nodes.yaml'
  if File.exists?(File.dirname(__FILE__) + '/../nodes.yaml')
    nodes_yaml_path = File.dirname(__FILE__) + '/../nodes.yaml'
  end

  config_yaml = YAML.load_file(nodes_yaml_path)
  config_yaml['nodes'].each do |vm_id, settings|
    cfg.vm.define(vm_id) do |config|
      if settings.has_key?('enable') and settings['enable'] != true
        next
      end

      domain = get('domain', config_yaml, settings)
      base_box = get('base_box', config_yaml, settings)
      synced_folders = config_yaml['defaults']['synced_folders'] || []
      synced_folders.concat(settings['synced_folders'] || [])
      osfam = get('osfam', config_yaml, settings)

      config.vm.box = base_box
      config.vm.host_name = vm_id + '.' + domain

      base_box_basedir = get('base_box_basedir', config_yaml, settings)
      base_box_url = get('base_box_url', config_yaml, settings)
      if base_box_basedir
        config.vm.box_url = 'file://' + __dir__ + '/' + base_box_basedir + '/' + base_box
      elsif base_box_url
        config.vm.box_url = base_box_url
      end

      # Networking
      #config.vm.network :forwarded_port, guest: 22, host: 2222 #TODO make this configurable

      if settings.has_key?('ip')
        config.vm.network 'private_network', ip: settings['ip']
      else
        config.vm.network 'private_network', type: 'dhcp'
      end

      # Folders/ Sharing
      config.vm.synced_folder '.', '/vagrant', disabled: true
      synced_folders.each do |folder|
        src = folder['src']
        src += "/#{osfam}" if folder['dst'].match(/\/scripts\/?/)
        config.vm.synced_folder(src, folder['dst'])
      end


      # Plugins
      if Vagrant.has_plugin?('vagrant-cachier')
         config.cache.scope = :box
      end

      # Providers
      config.vm.provider 'virtualbox' do |vb|
        vb.gui = get('gui', config_yaml, settings)
        #vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        #vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        vb.customize ['modifyvm', :id, '--hpet', 'on']
        vb.customize ['modifyvm', :id, '--ioapic', 'on']

        cpus = get('cpus', config_yaml, settings)
        vb.cpus = cpus if cpus
        memory = get('memory', config_yaml, settings)
        vb.memory = memory if memory
      end

      config.vm.provider :linode do |provider, override|
        # Linode Provider tested with https://github.com/displague/vagrant-linode
        override.ssh.private_key_path = get('linode_private_key_path', config_yaml, settings) || '~/.ssh/id_rsa'

        provider.token = get('linode_token', config_yaml, settings)
        provider.distribution = get('os', config_yaml, settings) || 'Debian 8'
        provider.datacenter = get('datacenter', config_yaml, settings) || 'london'
        provider.plan = get('plan', config_yaml, settings) || 'Linode 1024'
        # provider.planid = <int>
        # provider.paymentterm = <*1*,12,24>
        # provider.datacenterid = <int>
        # provider.image = <string>
        # provider.imageid = <int>
        provider.private_networking = get('linode_private_network', config_yaml, settings)
        # provider.stackscript = <string>
        # provider.stackscriptid = <int>
        # provider.distributionid = <int>
      end

      # Provision #TODO merge is not working at the moment (ordering broken) concat => push?
      global_provision = config_yaml['defaults']['provision'] || []
      provision = settings['provision'] || []
      provision.concat(global_provision)

      provision.each do |prov|
        case(prov['name'])
        when 'saltstack_formulas'
          formulas = prov['formulas'] || {}
          formulas.each do |mod|
            src = mod['base_dir']
            if File.exists?(src)
              dst = '/vagrant/salt/formulas/' + mod['name']
              config.vm.synced_folder(src, dst)
            end
          end
        end

        if prov.has_key?('env')
          env_var_code = 'set -x'
          prov.fetch('env', []).each do |varname, varvalue|
            env_var_code += "\nexport ENV_#{prov['name']}_#{varname}=\"#{varvalue}\""
          end
          config.vm.provision 'shell', inline: "echo -e \"#{env_var_code}\" > /tmp/vagrant-provision-#{prov['name']}-env.sh"
        end

        src = 'assets/scripts/provision/provision.sh'
        #dst = '/tmp/vagrant-provision-' + prov['name'] + '.sh'
        #config.vm.provision 'file', source: src, destination: dst
        #config.vm.provision 'shell', inline: 'chmod u+x ' + dst
        config.vm.provision 'shell', path: src, args: [ prov['name'], osfam ]
      end
    end
  end
end
