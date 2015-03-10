# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Useful vagrant plugins:
#
# * vagrant-notify
# * cachier
#
require 'yaml'

# TODO add function that returns value based on global default and node-specific setting

Vagrant.require_version '>= 1.6.5'

Vagrant.configure('2') do |cfg|
  nodes_yaml_path = File.dirname(__FILE__) + '/nodes.yaml'
  if File.exists?(File.dirname(__FILE__) + '/../nodes.yaml') then
    nodes_yaml_path = File.dirname(__FILE__) + '/../nodes.yaml'
  end

  config_yaml = YAML.load_file(nodes_yaml_path)
  config_yaml['nodes'].each do |vm_id, settings|
    cfg.vm.define(vm_id) do |config|
      if settings.has_key?('enable') and settings['enable'] != true then
        next
      end

      domain = config_yaml['defaults']['domain'] || settings['domain']
      synced_folders = config_yaml['defaults']['synced_folders'].concat(settings['synced_folders'] || [])

      config.vm.box = settings['base_box']
      config.vm.box_url = 'file://' + __dir__ + '/' + settings['base_box_basedir'] + '/' + settings['base_box']
      config.vm.host_name = vm_id + '.' + domain
      if settings.has_key?('ip') then
        config.vm.network 'private_network', ip: settings['ip']
      else
        config.vm.network 'private_network', type: 'dhcp'
      end
      synced_folders.each do |folder|
        config.vm.synced_folder(folder['src'], folder['dst'])
      end
      #config.ssh.private_key_path = BOX_PRIV_KEY.split(',')


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

      # Provision
      global_provision = config_yaml['defaults']['provision'] || []
      provision = settings['provision'] || []
      provision.concat(global_provision)

      provision.each do |prov|
        case(prov['name'])
        when 'basic'
          config.vm.provision 'shell', inline: 'find /vagrant/scripts/' + prov['name'] + '/ -name \'*.sh\' -exec {} \; 1>> /var/tmp/vagrant-provision-' + prov['name'] + '.log'
        when 'saltstack_setup'
          config.vm.provision 'shell', inline: 'find /vagrant/scripts/' + prov['name'] + '/ -name \'*.sh\' -exec {} \; &>> /var/tmp/vagrant-provision-' + prov['name'] + '.log'
        when 'saltstack_modules', 'saltstack_minion', 'saltstack_master'
          formulas = prov['formulas'] || {}
          formulas.each do |mod|
            src = mod['base_dir'] #+ '/' + mod['name']
            if File.exists?(src) then
              dst = '/vagrant/salt/formulas/' + mod['name']
              config.vm.synced_folder(src, dst)
            end

            #folders = mod['folders'] || ['_grains', '_modules', '_states', 'contrib', 'pillar_examples', 'states']
            #folders.each do |folder|
            #  src = mod['base_dir'] + '/' + folder
            #  if File.exists?(src) then
            #    dst = '/vagrant/salt/formulas/' + mod['name'] + '/' + folder
            #    config.vm.synced_folder(src, dst)
            #  end
            #end

            if prov.has_key?('modules_custom') then
              config.vm.synced_folder(prov['modules_custom'], '/vagrant/salt/_modules')
            end

            #src = mod['base_dir']
            #if File.exists?(src) then
            #  dst = '/vagrant/salt/formulas/' + mod['name']
            #  config.vm.synced_folder(src, dst)
            #end
          end

          config.vm.provision 'shell', inline: 'find /vagrant/scripts/' + prov['name'] + '/ -name \'*.sh\' -exec {} \; &>> /var/tmp/vagrant-provision-' + prov['name'] + '.log'
        else
          abort('Don\'t know provision type ' + prov['name'])
        end
      end

    end
  end
end
