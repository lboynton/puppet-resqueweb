# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation errors
# and view a log of events) or by fully applying the test in a virtual environment
# (to compare the resulting system state to the desired state).
#
# Learn more about module testing here: http://docs.puppetlabs.com/guides/tests_smoke.html
#

include epel

package { 'redis':
	ensure 	=> installed,
	require => Class['epel'],
}

user { 'deploy':
	ensure 		=> present,
	managehome 	=> true,
}

group { 'nogroup':
	ensure	=> present,
}

rbenv::install { 'deploy': }

rbenv::compile { '1.9.3-p327':
	user 	=> 'deploy',
	global 	=> true,
}

rbenv::gem { "unicorn":
    user => "deploy",
    ruby => "1.9.3-p327",
}

include resqueweb