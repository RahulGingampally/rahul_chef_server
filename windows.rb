#
# Cookbook Name:: java_install
# Recipe:: windows
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

hidden_folderpath           ="C:\\chef\\#{node['java_install']['hidden_folder_windows']}"
javapath                    ='C:\\Program Files\\Java\\jdk1.8.0_121\\bin'
jrepath                     ='C:\\Program Files\\Java\\jre1.8.0_121\\bin'


hidden_folder_windows      = node['java_install']['hidden_folder_windows']
s3_bucket_name             =node['java_install']['s3_bucket_name']
s3package_windows          =node['java_install']['s3package_windows']
s3windows_jdkinstaller     =node['java_install']['s3windows_jdkinstaller']
s3windows_jreinstaller     =node['java_install']['s3windows_jreinstaller']


#Create place holder as hidden folder

cofi_iis_hiddenfolder  hidden_folderpath do
  action :create
end.run_action(:Create)

directory "#{hidden_folderpath}\\archive" do
  action :create
  recursive true
  end.run_action(:Create)


  #Download JDK from s3
  cofi_iis_s3 s3windows_jdkinstaller do
   bucketname s3_bucket_name
   downloadtopath hidden_folderpath
 end.run_action(:run)

  #Download JRE from s3
  cofi_iis_s3 s3windows_jreinstaller do
   bucketname s3_bucket_name
   downloadtopath hidden_folderpath
 end.run_action(:run)


 #Installing JDK silently
 powershell_script "Install JDK" do
 cwd hidden_folderpath
 code <<-EOH
  start-process jdk-8u121-windows-x64.exe '/s /L c:\\JdkSetup.log' -wait
  EOH
  not_if { ::File.exist?("C:\\Program Files\\Java\\jdk1.8.0_121\\bin\\javac.exe")}
 end


  #Installing JRE silently
  powershell_script "Install JRE" do
  cwd hidden_folderpath
  code <<-EOH
   start-process jre-8u121-windows-x64.exe '/s /L c:\\JRESetup.log' -wait
   EOH
   not_if { ::File.exist?("C:\\Program Files\\Java\\jre1.8.0_121\\bin\\javax.exe")}
  end

 env 'path' do
   value javapath
   delim ';'
   action :modify
 end

 env 'JAVA_HOME' do
   value jrepath
 end

env 'JDK_HOME' do
  value javapath
end

env 'JRE_HOME' do
  value jrepath
end

#Changing file permission of dll

file 'C:\\Program Files\\Java\\jre1.8.0_121\\bin\\server\\jvm.dll' do
  rights :full_control, 'Users'
end
