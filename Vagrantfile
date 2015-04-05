# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Useful vagrant plugins:
#
# * vagrant-notify
# * cachier
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
      synced_folders.each do |folder|
        if folder['dst'].match(/\/scripts\/?$/)
          folder['src'] += '/' + osfam
        end
        config.vm.synced_folder(folder['src'], folder['dst'])
      end


      # Plugins
      if Vagrant.has_plugin?('vagrant-cachier')
         config.cache.scope = :box
      end

      # Providers
      config.vm.provider 'virtualbox' do |vb|
        vb.gui = false
        #vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        #vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        vb.customize ['modifyvm', :id, '--hpet', 'on']
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

        src = 'assets/scripts/provision/provision.sh'
        dst = '/tmp/vagrant-provision-' + prov['name'] + '.sh $@'
        config.vm.provision 'file', source: src, destination: dst
        config.vm.provision 'shell', inline: dst, args: [ prov['name'], osfam ]
      end
    end
  end
end
