require 'user_service.rb'
class UserController < ApplicationController


    def index
        t = params[:patient_not_found]
        if params[:patient_not_found] == 'yes'
            @patient_not_found = ""
        end
        render :layout => false
    end


    def log

     
    end


    def authentication
        username = params[:user][:username]
        password = params[:user][:password]
        
        status = UserService.authenticate(username,password)
       
        if status[0] == true           
            token = status[1]['authorization']['token']
            user_id = status[1]['authorization']['user']['user_id']
            f_name = status[1]['authorization']['user']['person']['names'][0]['given_name']
            s_name = status[1]['authorization']['user']['person']['names'][0]['family_name']
            
            session['user'] = [token,user_id,f_name,s_name]
            redirect_to '/user/index'
        else
            redirect_to  '/', flash: {error: 'wrong username or password'} if status[1].message == "401 Unauthorized" 
            redirect_to  '/', flash: {error: 'wrong username or password'} if status[1].message == "500 Internal Server Error"            
        end           
        
    end


end
