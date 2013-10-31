default[:mmonit][:installation_name]    = "mmonit"
default[:mmonit][:version]              = "3.0"
default[:mmonit][:decompressed_dirname] = "mmonit-#{node[:mmonit][:version]}"
default[:mmonit][:download_url]         = "http://www.mmonit.com/dist/mmonit-#{node[:mmonit][:version]}-linux-x64.tar.gz"
default[:mmonit][:install_path]         = "/opt/"
default[:mmonit][:tmp_dir]              = "/tmp"

default[:mmonit][:user]                 = "mmonit"
default[:mmonit][:group]                = "mmonit"

default[:mmonit][:pid_path]             = "/var/run/mmonit"

default[:mmonit][:listen_host]          = "0.0.0.0"
default[:mmonit][:listen_port]          = 8080

default[:mmonit][:licence_key]          = ""
default[:mmonit][:licence_owner]        = ""
default[:mmonit][:web_admin_pass]       = "swordfish"
default[:mmonit][:db_type]              = "sqllite" #mysql postgresql
default[:mmonit][:db_user]              = "dbuser" # existing db username to connect with
default[:mmonit][:db_pass]              = "dbpass" # existing db pass to connect with
default[:mmonit][:db_name]              = "mmonit" # new database name
default[:mmonit][:mmonit_db_user]       = "mmonit" # new db user to create for mmonit
default[:mmonit][:mmonit_db_pass]       = "password" # new db pass to create for monit
