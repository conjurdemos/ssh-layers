policy "docker-ssh-layers-1.0" do
  alice  = user "alice"
  donna  = user "donna"
  claire = user "claire"

  [ alice, donna, claire ].each do |user|
    user_dir = [ "users", user.login ].join('/')
    FileUtils.mkdir_p user_dir
    Dir.chdir user_dir do
      Conjur.log << "Generating key pair for #{user.login}\n" if Conjur.log
      
      require 'openssl'
      require 'fileutils'
      
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      private_key = rsa_key.to_pem
      public_key = rsa_key.public_key.to_pem
      
      File.write('id_rsa', private_key)
      FileUtils.chmod 0600, 'id_rsa'
      File.write('id_rsa.pub', public_key)
      
      public_key = [ `ssh-keygen -y -f id_rsa`.strip, user.login ].join(' ')

      api.add_public_key user.login, public_key
    end
  end

  
  admin = group "admin" do
    add_member alice
  end
  
  developers = group "developers" do
    add_member donna
  end
  
  layer "development" do
    dev_0 = host "dev-0" do |host|
      host.resource.annotations[:port] = 2300
    end
    add_host dev_0

    add_member "use_host", developers
    add_member "admin_host", admin
  end
  
  layer "production" do
    prod_0 = host "prod-0" do |host|
      host.resource.annotations[:port] = 2400
    end
    add_host prod_0

    add_member "admin_host", admin
  end
end
