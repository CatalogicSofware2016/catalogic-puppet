
export RUBYLIB=/root/ecx/lib
export ECXUSER=admin
export ECXPASSWORD=catal0gic

#puppet apply ./copypolicy.pp 
puppet apply ./copypolicy.pp --trace
#puppet apply ./copypolicy.pp  --debug -
