
require 'puppet/provider'
require 'net/http'
require 'net/https'
require 'json'
require 'pp'



class ConnectInfo 

 def initialize(server, user,password)  
    # Instance variables  
    @server = server
    @user = user
    @password = password
    @sessionid = ''
    @path = ''
  end   

 def path=(new_path)
  @path = new_path
 end

 def path
  @path
 end

 def server
   @server
 end

 def user
  @user
 end

 def password
  @password
 end

 def sessionid=(new_sessionid)
  @sessionid = new_sessionid
 end

 def sessionid
  @sessionid
 end


end


