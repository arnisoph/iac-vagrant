# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Useful vagrant plugins:
#
# * vagrant-notify
# * cachier
#
require 'yaml'

Vagrant.require_version ">= 1.6.5"

Vagrant.configure("2") do |cfg|

  nodes = YAML.load_file("../nodes.yaml")

  nodes.each do |vm_id, settings|
    cfg.vm.define(vm_id) do |config|

      if settings.has_key?('enable') and settings['enable'] != true then
        next
      end

      config.vm.box = settings['base_box']
      config.vm.box_url = 'file://' + __dir__ + '/' + settings['base_box_basedir'] + '/' + settings['base_box']
      config.vm.host_name = vm_id + '.' + settings['domain']
      #config.ssh.private_key_path = BOX_PRIV_KEY.split(',')


      # Plugins
      if Vagrant.has_plugin?('vagrant-cachier')
         config.cache.scope = :box
      end

      # Providers
      config.vm.provider 'virtualbox' do |vb|
        vb.gui = false
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ['modifyvm', :id, '--hpet', 'on']
      end

      # Provision
      provision = settings['provision'].each || []
      provision.each do |prov|
        modules = prov['modules'] || {}

        case(prov['name'])
        when 'saltstack'
          modules.each do |mod|
            folders = mod['folders'] || ['_grains', '_modules', '_states', 'contrib', 'pillar', 'states']
            folders.each do |folder|
              src = mod['base_dir'] + '/' + folder
              if File.exists?(src) then
                dst = '/vagrant/salt/formulas/' + mod['name'] + '/' + folder
                config.vm.synced_folder(src, dst)
              end
            end

            src = mod['base_dir'] + '/' + mod['name']
            if File.exists?(src) then
              dst = '/vagrant/salt/formulas/' + mod['name'] + '/states'
              config.vm.synced_folder(src, dst)
            end
          end
        else
          abort('Don\'t know provision type ' + prov['name'])
        end
      end

      # TODO the following is salt specific
      #config.vm.syncedwfolder "../../../../github/salt-modules/_modules", "/vagrant/salt/_modules", disabled: false
    end
  end
end
