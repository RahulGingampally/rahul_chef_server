#
# Cookbook Name:: java_install
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


if node ["platform"] == 'windows'
  include_recipe 'java_install::windows'
end

if node ["platform"] == 'redhat'
  include_recipe 'java_install::redhat'
end

if node ["platform"] == 'ubuntu'
  include_recipe 'java_install::ubuntu'
end
