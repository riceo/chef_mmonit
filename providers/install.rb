action :install do

    if new_resource.group != new_resource.user then
        group = new_resource.group
    else
        group = nil
    end

    user new_resource.user do
      comment "M/Monit User"
      gid gid
      system true
    end

    directory "#{new_resource.pid_path}" do
        user new_resource.user
        group new_resource.group
    end

    remote_file "#{new_resource.tmp_dir}/mmonit.tar.gz" do
        source new_resource.download_url
        not_if { ::File.exists?("#{new_resource.install_path}/#{new_resource.decompressed_dirname}") }
        user new_resource.user
        group new_resource.group
        notifies :create, "directory[mmonit_dir]", :immediately
    end

    directory "mmonit_dir" do
        path "#{new_resource.install_path}/#{new_resource.decompressed_dirname}"
        user new_resource.user
        group new_resource.group
        action :nothing
        notifies :run, "execute[install_mmonit]", :immediately
    end

    execute "install_mmonit" do
        command "tar -xzvf #{new_resource.tmp_dir}/mmonit.tar.gz"\
                "&& mv #{new_resource.decompressed_dirname}/* #{new_resource.install_path}/#{new_resource.decompressed_dirname}/"\
                "&& chown -R #{new_resource.user}:#{new_resource.group} #{new_resource.install_path}/#{new_resource.decompressed_dirname}/"
        action :nothing
    end

    if %w{mysql postgresql}.include? new_resource.db_type and not node[:mmonit][:db_installed] then

        case new_resource.db_type
        when "mysql" # UNTESTED!!

            execute "mysql -U #{new_resource.db_user} -p#{new_resource.db_pass} -e "\
                    "'CREATE DATABASE #{new_resource.db_name}; USE #{new_resource.db_name};"\
                    "GRANT ALL ON #{new_resource.db_name}.* to #{new_resource.mmonit_db_user}@localhost"\
                    "identified by '#{new_resource.mmonit_db_pass}''"

            execute "mysql -u #{new_resource.mmonit_db_user} #{new_resource.db_name} -p#{new_resource.mmonit_db_pass} "\
                    "< #{new_resource.install_path}/#{new_resource.decompressed_dirname}/db/monit-schema.mysql"

        when "postgresql"
            execute "echo \"CREATE ROLE #{new_resource.mmonit_db_user} WITH ENCRYPTED PASSWORD '#{new_resource.mmonit_db_pass}' LOGIN;\""\
                    "| psql -h 127.0.0.1 -U #{new_resource.db_user}"

            execute "echo \"CREATE DATABASE #{new_resource.db_name} WITH OWNER = #{new_resource.mmonit_db_user}\""\
                    "| psql -h 127.0.0.1 -U #{new_resource.db_user}"

            execute "echo \"GRANT ALL ON DATABASE #{new_resource.db_name} TO #{new_resource.mmonit_db_user};\""\
                    "| psql -h 127.0.0.1 -U #{new_resource.db_user}"

            execute "psql -h 127.0.0.1 -U #{new_resource.db_user} #{new_resource.db_name}"\
                    " < #{new_resource.install_path}/#{new_resource.decompressed_dirname}/db/mmonit-schema.postgresql"

            execute "echo \"GRANT ALL ON ALL TABLES IN SCHEMA public TO #{new_resource.mmonit_db_user}\""\
                    "| psql -h 127.0.0.1 -U #{new_resource.db_user} #{new_resource.db_name}"
        end

        node.normal[:mmonit][:db_installed] = true

    end

    case new_resource.db_type
    when "postgresql"
            execute "echo \"UPDATE users SET password=md5('#{new_resource.web_admin_pass}') WHERE uname='admin'\""\
                    " | psql -h 127.0.0.1 -U #{new_resource.db_user} #{new_resource.db_name}"
    when "mysql" #UNTESTED!!
        execute "mysql -U #{new_resource.db_user} -p#{new_resource.db_pass} #{new_resource.db_name} -e "\
                "'UPDATE users SET password=MD5(\'#{new_resource.web_admin_pass}\') WHERE uname = \'admin\''"
    end

    template "/opt/mmonit-3.0/conf/server.xml" do
        cookbook "mmonit"
        variables({
            :db_type        => new_resource.db_type,
            :mmonit_db_user => new_resource.mmonit_db_user,
            :mmonit_db_pass => new_resource.mmonit_db_pass,
            :db_name        => new_resource.db_name,
            :licence_owner  => new_resource.licence_owner,
            :licence_key    => new_resource.licence_key
        })
        user new_resource.user
        group new_resource.group
    end

    template "/etc/init.d/#{new_resource.installation_name}" do
        variables({
            :installation_name => new_resource.installation_name,
            :install_path      => "#{new_resource.install_path}/#{new_resource.decompressed_dirname}",
            :pid_path          => new_resource.pid_path,
            :mmonit_user       => new_resource.user
        })
        mode 0755
        source "init.erb"
        cookbook "mmonit"
    end

    service new_resource.installation_name do
        supports :status => true, :restart => true, :reload => true
        action [ :enable, :start ]
    end

end

action :remove do

end