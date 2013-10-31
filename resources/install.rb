actions :install, :remove

attribute :install_path, :kind_of => String, :name_attribute => true
attribute :installation_name, :kind_of => String
attribute :tmp_dir, :kind_of => String
attribute :user, :kind_of => String
attribute :group, :kind_of => String
attribute :version, :kind_of => String
attribute :decompressed_dirname, :kind_of => String
attribute :download_url, :kind_of => String
attribute :pid_path, :kind_of => String
attribute :listen_host, :kind_of => String
attribute :listen_port, :kind_of => Integer
attribute :licence_key, :kind_of => String
attribute :licence_owner, :kind_of => String
attribute :web_admin_pass, :kind_of => String

attribute :db_type, :kind_of => String
attribute :db_user, :kind_of => String
attribute :db_pass, :kind_of => String
attribute :mmonit_db_user, :kind_of => String
attribute :mmonit_db_pass, :kind_of => String
attribute :db_name, :kind_of => String