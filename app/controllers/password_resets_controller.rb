class PasswordResetsController < ApplicationController

	def new 
		
	end
	
	def create
		user = User.find_by(email: params[:email])
		if user != nil
	
			user.generate_password_reset_token!
	    	PasswordReset.email(user).deliver
	    	flash[:success] = 'Password email has been sent'
	    	redirect_to login_path
		else 
			flash[:danger] = 'We couldn\'t find that email, please try again'
			render 'new'
		end
    	
	end
end
