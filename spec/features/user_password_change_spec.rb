require "rails_helper" 

RSpec.feature "User Password Reset" do
	before do
		@user = User.create(username: "non admin", password: 'password', admin: false)
	end	
	
	scenario "generate password reset token" do
		expect {@user.generate_password_reset_token!}.to change{@user.password_reset_token}
	end
end