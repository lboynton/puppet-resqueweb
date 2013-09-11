# == Class: resqueweb
#
# Full description of class resqueweb here.
#
# === Parameters
#
#  [app_name]
#  We need an app name which refers to the path where the app is installed. This is needed for the init script.
#
#  [redis_host]
#  As it name states this is our Redis server.
#
#  [redis_port]
#  Redis port on which we are going to connect. By default 6371
#
#  [stages]
#  On our actual infrastructure we have 5 development environments. In order to manage all resques
#  using only one resqueweb @areina decided that the best idea was to get the URL from the browser
#  and acording to the stage on [stage].domain.com get the namespaces from our redis instance. And
#  he was right. So on this parameter you can add comma separated all environments you want to use.
#
#  [unicorn_port]
#  Did we mention that we run resqueweb on top of unicorn? well this is the place were you can configure
#  unicorn's port for resqueweb.
#
#  [worker_processes]
#  We currently use 2 worker processes to handle Resqueweb connections, even 1 should be enough.
#
# === Requires
#
# alup/puppet-rbenv
#   Ruby 1.9.3
#   Bundler Gem
#
# === USAGE
# On your site.pp or nodes.pp add
#
# include resqueweb
#
# On this manifest add:
# Ensure config.ru exists
#    resqueweb::resource::config {
#      'config.ru':
#        redis_host => 'redis01.domain.com',
#        redis_port => '6374'
#        stages     => 'production',
#      }
#    }
#
# Ensure Unicorn.rb exists
#
#    resqueweb::resource::unicorn {
#      'unicorn.rb':
#        unicorn_port     => '8064',
#        worker_processes => '2'
#    }
#
# Ensure We have a unicorn init for resqueweb
#    resqueweb::resource::init {
#      'unicorn-queues':
#        app_name => 'resqueweb'
#    }
#
# === Authors
#
# Rhommel Lamas <roml@rhommell.com>
# Twitter @rhoml
#
# === Copyright
#
# Copyright (c) 2012 Rhommel Lamas

# MIT License

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

class resqueweb {
  include resqueweb::install

  resqueweb::resource::config {
    'config.ru':
      stages     => 'production',
      redis_host => 'redis01.domain.com',
      redis_port => '6374'
  }

  resqueweb::resource::unicorn {
    'unicorn.rb':
      unicorn_port     => '8064',
      worker_processes => '2'
  }

  resqueweb::resource::init { 'unicorn-queues': app_name => 'resqueweb' }

  exec { "/etc/init.d/unicorn-queues restart":
    path        => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/home/${user}/.rbenv/shims" ],
    command     => "/etc/init.d/unicorn-queues restart",
    alias       => "restart-unicorn",
    refreshonly => true
  }
}
