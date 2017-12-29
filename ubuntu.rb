#
# Cookbook Name:: java_install
# Recipe:: ubuntu
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


file_path                     =node['java_install']['file_path']
hidden_folder_linux           =node['java_install']['hidden_folder_linux']
s3_bucket_name               =node['java_install']['s3_bucket_name']
s3package_linux              =node['java_install']['s3package_linux']
s3redhat_jdkinstaller        =node['java_install']['s3redhat_jdkinstaller']
s3redhat_jreinstaller        =node['java_install']['s3redhat_jreinstaller']


#Get some yum update
execute 'yum-update' do
  command 'yum-update -y'
end

#Create a hidden folder
directory "/etc/chef/#{hidden_folder_linux}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end.run_action(:create)

#Download JDk from s3
aws_s3_file "/etc/chef/#{hidden_folder_linux}/#{s3redhat_jdkinstaller}" do
   bucketname s3_bucket_name
   remote_path s3package_linux + s3redhat_jdkinstaller
   action :create_if_missing
end

#Install JDKpackage
execute 'unzip-jdk' do
 cwd "/etc/chef/#{hidden_folder_linux}"
 command "tar xzvf /etc/chef/#{hidden_folder_linux}/#{s3ubuntu_jdkinstaller} -C /opt"
 not_if { File.exists?("/opt/jdk1.8.0_121")}
end

#Update the profile with environment variables
file '/etc/profile' do
mode 00755
end

ruby_block 'Set JAVA_HOME in /etc/profile' do

  file = Chef::Util::FileEdit.new('/etc/profile')
  file.insert_line_if_no_match(/^JAVA_HOME=/, "JAVA_HOME=#{node['java_install']['java_home']}")
  file.search_file_replace_line(/^JAVA_HOME=/, "JAVA_HOME=#{node['java_install']['java_home']}")
  file.insert_line_if_no_match(/^PATH=/, "PATH=#{node['java_install']['java_path']}")
  file.search_file_replace_line(/^PATH=/, "PATH=#{node['java_install']['java_path']}")
  file.write_file
end
end

#Update the environment variables

bash 'reload env variables' do
 code <<-EOH
  source /etc/profile
  EOH
end
