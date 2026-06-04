#!/usr/bin/env bash

apt-get update
apt-get install -y python3 default-jre # python3-pip
# a simple two-panel file commander
apt-get install -y mc
# uncomment one of the following for graphical desktops
# NOTE: the graphical desktop is accessible through
# the main VirtualBox window (Show button)
#
# - minimal: wm & graphical server
# apt-get install -y icewm xinit xterm python3-tk
#
# - minimal desktop env: lxqt
# apt-get install -y xinit lxqt
#
# The recommended alternative to a graphical desktop
# is: Tigervnc, the kitty terminal emulator,
# the emacs editor and fluxbox as window manager.
# (We are also installing a couple of other popular WMs for convenience.)
# Remember to install the Tigervnc client in the host OS!
apt-get install -y tigervnc-standalone-server kitty emacs fluxbox fvwm icewm
if ! grep ":10=vagrant" /etc/tigervnc/vncserver.users; then
  echo ":10=vagrant" >> /etc/tigervnc/vncserver.users
fi
# set a password for Tigervnc
mkdir /home/vagrant/.vnc
if ! [ -a /home/vagrant/.vnc/passwd ]; then 
  pass=$'bda2024\nbda2024\nn\n'
  echo "$pass" | tigervncpasswd /home/vagrant/.vnc/passwd
fi
# Create the configuration file for Tigervnc:
# Configure FVWM as WM, set the geometry of the virtual desktop,
# and confine connections to the guest OS. (We'll use a ssh tunnel
# to connect from the host OS.) 
# To launch another WM, 
# edit /home/vagrant/.vnc/config to change the session value
if ! [ -a /home/vagrant/.vnc/config ]; then
  echo session=icewm >> /home/vagrant/.vnc/config
  echo geometry=1920x1080 >> /home/vagrant/.vnc/config
  echo localhost >> /home/vagrant/.vnc/config
fi  
# change the ownership of the config and passwd file to user vagrant
chown -R vagrant.vagrant /home/vagrant/.vnc
# start the VNC server
if ! systemctl is-enabled tigervncserver@:10.service; then
  systemctl enable tigervncserver@:10.service
fi
systemctl restart tigervncserver@:10.service
# cd to the shared  directory
# *** NOTE: we must comment it out on MacOS, as of 2024-10-25
# as there is no /vagrant shared folder out-of-the-box
cd /vagrant
# python packages
pip3 install matplotlib pandas seaborn jupyter pyspark==3.5.1
# remove previous Spark version
rm -rf /usr/local/spark-3.0.0-preview2-bin-hadoop2.7
if ! [ -d /usr/local/spark-3.2.0-bin-hadoop3.2 ]; then
# current link as of 2021-11-17:
  wget https://dlcdn.apache.org/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz
# wget https://www.apache.org/dyn/closer.lua/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz
  tar -C /usr/local -xvzf spark-3.5.3-bin-hadoop3.tgz
  rm spark-3.5.3-bin-hadoop3.tgz
fi

if ! [ -d /usr/local/hadoop-3.4.0 ]; then
  wget https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
  tar -C /usr/local -xvzf hadoop-3.4.0.tar.gz
  chown --recursive ubuntu:ubuntu /usr/local/hadoop-3.4.0
  rm hadoop-3.4.0.tar.gz
fi

if ! grep "export HADOOP_INSTALL=/usr/local/hadoop-3.4.0" /home/vagrant/.bashrc; then
  echo "export HADOOP_INSTALL=/usr/local/hadoop-3.4.0" >>  /home/vagrant/.bashrc
fi
if ! grep "export HADOOP_HOME=/usr/local/hadoop-3.4.0" /home/vagrant/.bashrc; then
  echo "export HADOOP_HOME=/usr/local/hadoop-3.4.0" >>  /home/vagrant/.bashrc
fi
if ! grep "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" /home/vagrant/.bashrc; then
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" >>  /home/vagrant/.bashrc
fi
if ! grep "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" /usr/local/hadoop-3.4.0/etc/hadoop/hadoop-env.sh; then
  echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/" >>  /usr/local/hadoop-3.4.0/etc/hadoop/hadoop-env.sh
fi
if ! grep "export HADOOP_INSTALL=/usr/local/hadoop-3.4.0" ~/.bashrc; then
  echo "export HADOOP_INSTALL=/usr/local/hadoop-3.4.0" >>  ~/.bashrc
fi
#if ! grep "export PYSPARK_PYTHON=/usr/bin/python3" /home/vagrant/.bashrc; then
  echo "export PYSPARK_PYTHON=/usr/bin/python3" >> /home/vagrant/.bashrc
fi

# ── Spark environment ─────────────────────────────────────────────────────────
if ! grep "export SPARK_HOME" /home/vagrant/.bashrc; then
  echo "export SPARK_HOME=/usr/local/spark-3.5.3-bin-hadoop3" >> /home/vagrant/.bashrc
fi
if ! grep "export PYTHONPATH.*pyspark" /home/vagrant/.bashrc; then
  echo 'export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH' >> /home/vagrant/.bashrc
fi

# ── Unified PATH: Hadoop + Spark binaries always available ───────────────────
if ! grep "SPARK_HOME/bin" /home/vagrant/.bashrc; then
  echo 'export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH' >> /home/vagrant/.bashrc
fi

# Apply the same exports for root (used during provisioning)
export SPARK_HOME=/usr/local/spark-3.5.3-bin-hadoop3
export HADOOP_HOME=/usr/local/hadoop-3.4.0
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PYSPARK_PYTHON=/usr/bin/python3
export PATH=$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH

# ── Hadoop pseudo-distributed configuration ───────────────────────────────────
HADOOP_CONF=$HADOOP_HOME/etc/hadoop

# core-site.xml: NameNode address
if ! grep -q "fs.defaultFS" $HADOOP_CONF/core-site.xml 2>/dev/null; then
cat > $HADOOP_CONF/core-site.xml << 'XMLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
XMLEOF
fi

# hdfs-site.xml: single-node replication, namenode/datanode paths
if ! grep -q "dfs.replication" $HADOOP_CONF/hdfs-site.xml 2>/dev/null; then
cat > $HADOOP_CONF/hdfs-site.xml << 'XMLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/home/vagrant/hadoopdata/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/home/vagrant/hadoopdata/datanode</value>
  </property>
</configuration>
XMLEOF
fi

# Set up passwordless SSH for vagrant (Hadoop requires it)
if ! [ -f /home/vagrant/.ssh/id_rsa ]; then
  sudo -u vagrant ssh-keygen -t rsa -P '' -f /home/vagrant/.ssh/id_rsa
fi
sudo -u vagrant bash -c "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys"
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# Create HDFS data directories owned by vagrant
mkdir -p /home/vagrant/hadoopdata/namenode
mkdir -p /home/vagrant/hadoopdata/datanode
chown -R vagrant:vagrant /home/vagrant/hadoopdata

# Format NameNode (only if not already formatted)
if ! [ -d /home/vagrant/hadoopdata/namenode/current ]; then
  sudo -u vagrant $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# Jupyter config: always open /vagrant so the project notebook is visible
sudo -u vagrant jupyter notebook --generate-config 2>/dev/null || true
sudo -u vagrant bash -c "echo \"c.NotebookApp.notebook_dir = '/vagrant'\" >> /home/vagrant/.jupyter/jupyter_notebook_config.py"
sudo -u vagrant bash -c "echo \"c.ServerApp.notebook_dir = '/vagrant'\"  >> /home/vagrant/.jupyter/jupyter_notebook_config.py"
# switch to user ubuntu
sudo -i -u ubuntu bash << EOF
echo "Switched to user ubuntu"
if ! ( echo exit | ssh localhost ) ; then
  echo "Creating keys and authorizing"
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 0600 ~/.ssh/authorized_keys
fi
EOF
echo "Exited user ubuntu"
