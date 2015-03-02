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

  nodes.each do |id, settings|
    cfg.vm.define(id) do |config|

      if settings.has_key?('enable') and settings['enable'] != true then
        next
      end

      config.vm.box = settings['base_box']
      config.vm.box_url = "file://#{__dir__}/#{settings['base_box_basedir']}/#{settings['base_box']}"
      config.vm.host_name = "#{id}.#{settings['domain']}"
      #config.ssh.private_key_path = BOX_PRIV_KEY.split(',')


      # Plugins
      if Vagrant.has_plugin?("vagrant-cachier")
         config.cache.scope = :box
      end

      # Providers
      config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      # Provision
      # TODO the following is salt specific
      #config.vm.synced_folder "../../../../github/salt-modules/_modules", "/vagrant/salt/_modules", disabled: false
      folders = ["_grains", "_modules", "_states", "contrib", "pillar", "states"]
      folders.each do |dir|
        path = "#{settings['module_base_dir']}/#{dir}"
        if File.exists?(path) then
          config.vm.synced_folder path, "/vagrant/salt/formulas/TODO/#{dir}", disabled: false
        end
      end
    end
  end
end
