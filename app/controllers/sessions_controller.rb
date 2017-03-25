class SessionsController < ApplicationController

#http://billpatrianakos.me/blog/2013/10/19/case-insensitive-finder-methods-in-rails/ --> try this for case insensitive

    def new
    end
    
    def create
        user = User.find_by(username: params[:session][:username])
        #user = User.where("LOWER(username) = ?", params[:session][:username].downcase).limit(1)
        
        if user && user.authenticate(params[:session][:password])
            session[:user_id] = user.id
            #flash[:success] = "You have successfully logged in"
            redirect_to user_path(user) #go directly to user My Page
        else
            flash.now[:danger] = "There was something wrong with your login information"
            render 'new'
        end
    
    end
    
    def destroy
        session[:user_id] = nil
        #flash[:success] = "You have logged out"
        redirect_to root_path
    end

end