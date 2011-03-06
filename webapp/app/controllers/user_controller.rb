class UserController < ApplicationController
  def login
    user_name = request.parameters['user_name']
    password = request.parameters['password']
    
    ldap = Net::LDAP.new
	ldap.host = "ldap.example.com"
	ldap.auth("uid=#{user_name},ou=Users,dc=example,dc=com", password)
	
    is_authenticated = ldap.bind
    if is_authenticated then
    	User.find_or_create_by_username(user_name).save
        render :json => {:login => true}
    else
      render :json => {:error => "name/password is incorrect"}
    end
  end
end
