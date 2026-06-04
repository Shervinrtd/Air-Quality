# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Ubuntu 22.04
  config.vm.box = "ubuntu/jammy64"

  # ── Port forwarding ────────────────────────────────────────────────────────
  # Jupyter Notebook  → open http://localhost:8888 in your host browser
  config.vm.network "forwarded_port", guest: 8888, host: 8888, host_ip: "127.0.0.1"

  # Spark Web UI      → open http://localhost:4040 to monitor running jobs
  config.vm.network "forwarded_port", guest: 4040, host: 4040, host_ip: "127.0.0.1"

  # HDFS NameNode UI  → open http://localhost:9870 to browse HDFS
  config.vm.network "forwarded_port", guest: 9870, host: 9870, host_ip: "127.0.0.1"

  # YARN ResourceManager UI (optional)
  config.vm.network "forwarded_port", guest: 8088, host: 8088, host_ip: "127.0.0.1"

  # VNC display :10 (SSH tunnel still recommended for security)
  # Connect via:  vagrant ssh -- -L 5910:localhost:5910
  # Then open a VNC client to  localhost:5910  password: bda2024
  config.vm.network "forwarded_port", guest: 5910, host: 5910, host_ip: "127.0.0.1"

  # ── VM resources ───────────────────────────────────────────────────────────
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus   = 2
    vb.name   = "BigData-AirQuality-VM"
  end

  # ── Provisioning script ────────────────────────────────────────────────────
  config.vm.provision :shell, path: "bootstrap.sh"

end
