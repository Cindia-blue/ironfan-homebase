# -*- coding: utf-8 -*-
#
# El Ridiculoso Grande -- esto es un clúster gordo que tiene todo lo que en él
#
# Maybe you're wondering what would happen if you installed everything in sight
# on the same node. Here's your chance to find out.
#
Ironfan.cluster 'el_ridiculoso' do
  cloud(:ec2) do
    defaults
    availability_zones ['us-east-1d']
    flavor              'c1.xlarge'
    backing             'ebs'
    image_name          'ironfan-natty'
    bootstrap_distro    'ubuntu10.04-ironfan'
    chef_client_script  'client.rb'
    mount_ephemerals(:tags => { :hadoop_scratch => true })
  end

  environment           :dev

  role                  :systemwide
  role                  :chef_client
  role                  :ssh
  role                  :nfs_client

  role                  :volumes
  role                  :package_set
  role                  :minidash,   :last

  role                  :org_base
  role                  :org_final, :last
  role                  :org_users

  role                  :hadoop
  role                  :hadoop_s3_keys
  recipe                'hadoop_cluster::config_files', :last
  role                  :tuning, :last
  recipe                'cloud_utils::pickle_node'

  module ElRidiculoso
    module_function
    def master_processes
      role                :cassandra_server
      # role                :elasticsearch_data_esnode
      # role                :elasticsearch_http_esnode
      role                :zookeeper_server
      role                :flume_master
      role                :ganglia_master
      role                :hadoop_namenode
      role                :hadoop_jobtracker
      role                :hadoop_secondarynn
      role                :hbase_master
      role                :redis_server
      # role                :statsd_server
      # role                :mongodb_server
      # role                :mysql_server
      # role                :graphite_server
      # role                :resque_server
      # These run stuff even though they shouldn't
      recipe              'apache2'
      recipe              'nginx'
    end

    def worker_processes
      role                :hadoop_datanode
      role                :hadoop_tasktracker
      role                :flume_agent
      role                :ganglia_agent
      role                :hbase_regionserver
      role                :hbase_stargate
    end

    def client_processes
      role                :mysql_client
      role                :redis_client
      role                :cassandra_client
      role                :elasticsearch_client
      role                :nfs_client
    end

    def simple_installs
      role                :jruby
      role                :pig
      recipe              'ant'
      recipe              'bluepill'
      recipe              'boost'
      recipe              'build-essential'
      recipe              'cron'
      recipe              'git'
      recipe              'hive'
      recipe              'java::sun'
      recipe              'jpackage'
      recipe              'jruby'
      recipe              'nodejs'
      recipe              'ntp'
      recipe              'openssh'
      recipe              'openssl'
      recipe              'rstats'
      recipe              'runit'
      recipe              'thrift'
      recipe              'xfs'
      recipe              'xml'
      recipe              'zabbix'
      recipe              'zlib'
    end
  end

  facet :gordo do
    extend ElRidiculoso
    instances           1

    # master_processes
    # worker_processes
    # client_processes
    # simple_installs
  end

  facet :jefe do
    extend ElRidiculoso
    instances           1

    master_processes
    simple_installs
  end

  # Runs worker processes and client packages
  facet :bobo do
    extend ElRidiculoso
    instances           1

    worker_processes
    client_processes
    simple_installs
  end

  cluster_role.override_attributes({
      :hadoop => {
        :java_heap_size_max    => 128,
      },
    })

  cluster_role.override_attributes({
      :apache         => {
        :server       => { :run_state => :stop  }, },
      :cassandra      => { :run_state => :stop  },
      :chef           => {
        :client       => { :run_state => :stop  },
        :server       => { :run_state => :stop  }, },
      :elasticsearch  => { :run_state => :stop  },
      :flume          => {
        :master       => { :run_state => :stop  },
        :node         => { :run_state => :stop  }, },
      :ganglia        => {
        :agent        => { :run_state => :stop  },
        :server       => { :run_state => :stop  }, },
      :graphite       => {
        :carbon       => { :run_state => :stop  },
        :whisper      => { :run_state => :stop  },
        :dashboard    => { :run_state => :stop  }, },
      :hadoop         => {
        :namenode     => { :run_state => :stop  },
        :secondarynn  => { :run_state => :stop  },
        :jobtracker   => { :run_state => :stop  },
        :datanode     => { :run_state => :stop  },
        :tasktracker  => { :run_state => :stop  },
        :hdfs_fuse    => { :run_state => :stop  }, },
      :hbase          => {
        :master       => { :run_state => :stop  },
        :regionserver => { :run_state => :stop  },
        :thrift       => { :run_state => :stop  },
        :stargate     => { :run_state => :stop  }, },
      :jenkins        => {
        :server       => { :run_state => :stop  },
        :worker       => { :run_state => :stop  }, },
      :minidash       => { :run_state => :stop  },
      :mongodb        => {
        :server       => { :run_state => :stop  }, },
      :mysql          => {
        :server       => { :run_state => :stop  }, },
      :nginx          => {
        :server       => { :run_state => :stop  }, },
      :redis          => {
        :server       => { :run_state => :stop  }, },
      :resque         => {
        :redis        => { :run_state => :stop  },
        :dashboard    => { :run_state => :stop  }, },
      :statsd         => { :run_state => :stop  },
      :zabbix         => {
        :agent        => { :run_state => :stop  },
        :master       => { :run_state => :stop  }, },
      :zookeeper      => {
        :server       => { :run_state => :stop  }, },
    })

end
