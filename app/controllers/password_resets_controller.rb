class PasswordResetsController < ApplicationController

	def new 
		
	end
	
	def create
		user = User.find_by(email: params[:email])
		if user != nil
	
			user.generate_password_reset_token!
	    	PasswordReset.email(user).deliver
	    	flash[:success] = 'Password reset email has been sent'
	    	redirect_to login_path
		else 
			flash[:danger] = 'We couldn\'t find that email, please try again'
			render 'new'
		end
    	
	end
	
	def edit
		@user = User.find_by(password_reset_token: params[:id])
		if @user
		else
			redirect_to root_path
		end
	end
	
	def update
		@user = User.find_by(password_reset_token: params[:id])
		if @user
			if @user.update_attributes(user_params)
				@user.update_attribute(:password_reset_token, nil)
				session[:user_id] = @user.id
				flash[:success] = 'Password has been updated'
				redirect_to user_path(user)
			else
				flash.now[:danger] = "Passwords do not match"
				render action: 'edit'
			end
		else
			flash.now[:notice] = "Password reset token not found."
			render action: 'edit'
		end
	end

	private
		def user_params
			params.require(:user).permit(:password, :password_confirmation)
		end

end
