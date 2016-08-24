
#use the correct RUBYLIB path
#export RUBYLIB=/root/ecx/lib
export RUBYLIB=/Users/klad/Documents/src/puppet/ecx/lib


export ECXUSER=admin
export ECXPASSWORD=catal0gic

puppet apply ./copypolicy.pp 
#puppet apply ./copypolicy.pp --trace
#puppet apply ./copypolicy.pp  --debug 
