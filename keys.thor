require 'net/ssh'
require 'net/scp'
require 'thor'

class Keys < Thor
  CONFIG = YAML.load(File.read(File.expand_path("~/.kor")))
  SERVERS = CONFIG['servers']
  KEYS = CONFIG['keys']
  SSH_USER = CONFIG['ssh_user'] || "admin"
  
  desc "add SERVER KEY", "Adds an ssh key to the specified server's authorized_keys file."
  method_option :server => :string, :key => :string
  def add(server, key)
    f = download(server, "~/.ssh/authorized_keys")
    keys = []
    f.each {|e| keys << e.chomp }
    key = KEYS[key.to_sym]
    unless keys.include?(key)
      keys << key
      f = keys.join("\n")
      ssh_exec(server, "echo '#{key}' >> ~/.ssh/authorized_keys")
      #upload(server, f, "~/.ssh/authorized_keys")
    else
      puts "Duplicate key found."
    end
  end 
  
  desc "add_all KEY", "Adds an ssh key to all important server's authorized_keys file."
  method_option :key => :string
  def add_all(key)
    SERVERS.each do |k,v|
      puts "Adding to #{k} (#{v})..."
      add(v, key)
    end
  end
  
  private
  
    def upload(server, data, path, user=nil)
      # Net::SCP::upload!(server, user, data, path, :verbose=>true)
    end
  
    def download(server, path, user=nil)
      Net::SCP::download!(server, user || SSH_USER, path)
    end
  
    def ssh_exec(server, command, user=nil)
      returning "" do |output|
        Net::SSH.start(server, user || SSH_USER) do |ssh|
          output = ssh.exec("#{command}")
        end
      end
    end
  
    def returning(var)
      yield var
      var
    end
end
