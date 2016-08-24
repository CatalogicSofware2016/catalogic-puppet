
#export RUBYLIB=/root/ecx/lib
export RUBYLIB=/Users/klad/Documents/src/puppet/ecx/lib

export ECXUSER=admin
export ECXPASSWORD=catal0gic

#puppet apply ./copypolicy.pp 
#puppet apply ./usepolicy.pp --trace
#puppet apply ./copypolicy.pp  --debug -



puppet apply ./usepolicy_test.pp 
#puppet apply ./usepolicy_end.pp 
#puppet apply ./usepolicy_clone.pp 



