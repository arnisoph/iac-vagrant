# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Useful vagrant plugins:
#
# * vagrant-notify
# * vagrant-vbguest
#
# Thanks to:
#
# * https://stefanwrobel.com/how-to-make-vagrant-performance-not-suck
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
      synced_folder_type = get('synced_folder_type', config_yaml, settings) || 'default'
      osfam = get('osfam', config_yaml, settings)
      assets_dir = get('assets_dir', config_yaml, settings) || '../vagrant-assets'
      ruby_host_os = RbConfig::CONFIG['host_os']

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
      forward_ports = get('ports', config_yaml, settings) || {}
      forward_ports.each do |port|
        config.vm.network :forwarded_port, guest: port['guest'], host: port['host']
      end

      if settings.has_key?('ip')
        config.vm.network 'private_network', ip: settings['ip']
      else
        config.vm.network 'private_network', type: 'dhcp'
      end

      # SSH
      ssh_config = get('ssh', config_yaml, settings) || {}
      if ssh_config
        config.ssh.username = ssh_config['username'] if ssh_config.has_key?('username')
        config.ssh.password = ssh_config['password'] if ssh_config.has_key?('password')
        config.ssh.insert_key = ssh_config['insert_key'] if ssh_config.has_key?('insert_key')
      end

      # Shared Folders
      assets_already_sycnced = false
      if synced_folder_type == 'nfs'
        config.vm.synced_folder('.', '/vagrant', disabled: true, type: 'nfs', mount_options: ['rw', 'vers=3', 'tcp', 'fsc' ,'actimeo=1'])
      else
        config.vm.synced_folder('.', '/vagrant', disabled: true)
      end
      synced_folders.each do |folder|
        src = folder['src']
        src += "/#{osfam}" if folder['dst'].match(/\/scripts\/?/) and File.exist?("#{folder['dst']}/#{osfam}") # assets dir
        if synced_folder_type == 'nfs'
          config.vm.synced_folder(src, folder['dst'], type: 'nfs', mount_options: ['rw', 'vers=3', 'tcp', 'fsc' ,'actimeo=1'])
        else
          config.vm.synced_folder(src, folder['dst'])
        end
        if folder['dst'] == '/vagrant/scripts'
          assets_already_sycnced = true
        end
      end

      if !assets_already_sycnced
        config.vm.synced_folder(assets_dir + '/scripts/provision/' + osfam, '/vagrant/scripts')
      end

      # Providers
      config.vm.provider 'virtualbox' do |vb|
        vb.gui = get('gui', config_yaml, settings)
        #vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        #vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        vb.customize ['modifyvm', :id, '--hpet', 'on']
        vb.customize ['modifyvm', :id, '--ioapic', 'on']

        # CPU Cores
        cpus = get('cpus', config_yaml, settings)
        if cpus
          vb.cpus = cpus
        elsif ruby_host_os =~ /darwin/
          vb.cpus = `sysctl -n hw.ncpu`.to_i
        elsif ruby_host_os =~ /linux/
          vb.cpus = `nproc`.to_i
        end

        # Memory
        memory = get('memory', config_yaml, settings)
        if memory
          vb.memory = memory
        elsif ruby_host_os =~ /darwin/
          # sysctl returns Bytes and we need to convert to MB
          vb.memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
        elsif ruby_host_os =~ /linux/
          # meminfo shows KB and we need to convert to MB
          vb.memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
        end

        # Local Storage
        extra_storage_base_path = get('extra_storage_base_path', config_yaml, settings) || '/tmp'
        extra_storage = get('extra_storage', config_yaml, settings) || []
        count = 0
        extra_storage.each do |disk|
          disk_path = extra_storage_base_path + '/' + vm_id + '_disk' + count.to_s + '.vdi'
          unless File.exist?(disk_path)
            vb.customize ['createhd', '--filename', disk_path, '--size', disk['size'] || 5 * 1024]
          end
          vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', count, '--type', 'hdd', '--medium', disk_path]
          count += 1
        end
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

      config.vm.provider :digital_ocean do |provider, override|
        # vagrant plugin install vagrant-digitalocean
        override.ssh.private_key_path = get('digitcalocean_private_key_path', config_yaml, settings) || '~/.ssh/id_rsa'
        provider.token = get('digitalocean_token', config_yaml, settings)
        provider.image = get('os', config_yaml, settings) || 'debian-8-x64'
        provider.region = get('datacenter', config_yaml, settings) || 'fra1'
        provider.private_networking = get('digitalocean_private_network', config_yaml, settings)
        provider.ipv6 = get('digitalocean_ipv6', config_yaml, settings) || true
        provider.size = get('digitalocean_size', config_yaml, settings) || '512mb'
      end

      # TODO PoC:
      #config.vm.provider :aws do |provider, override|
      #  # vagrant plugin install vagrant-aws
      #  provider.access_key_id = ''
      #  provider.secret_access_key = ''
      #  #provider.session_token = "SESSION TOKEN"
      #  provider.keypair_name = 'aws-ec2-home'
      #  provider.ami = ''
      #  provider.region = 'eu-central-1'
      #end

      # Provision #TODO merge is not working at the moment (ordering broken) concat => push?
      global_provision = config_yaml['defaults']['provision'] || []
      provision = settings['provision'] || []
      provision.concat(global_provision)

      provision.each do |prov|
        if prov['name'] == 'saltstack_formulas'
          formulas = prov['formulas'] || {}
          formulas.each do |mod|
            src = mod['base_dir']
            if File.exists?(src)
              dst = '/vagrant/salt/formulas/' + mod['name']
              config.vm.synced_folder(src, dst)
            end
          end
        end

        src = assets_dir + '/scripts/provision/provision.sh'
        #dst = '/tmp/vagrant-provision-' + prov['name'] + '.sh'
        #config.vm.provision 'file', source: src, destination: dst
        #config.vm.provision 'shell', inline: 'chmod u+x ' + dst
        config.vm.provision 'shell', env: prov['env'] || {}, path: src, args: [ prov['name'], osfam ]
      end
    end
  end
end
