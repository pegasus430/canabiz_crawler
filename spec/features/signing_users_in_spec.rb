require "rails_helper"

RSpec.feature "Users signin" do 
	
	before do 
		@user = User.create!(username: "username", password: "password", admin: false)	
	end
	
	scenario "with valid credentials" do 
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: @user.username
		fill_in "Password", with: @user.password
		click_button "Log in"
		
		expect(page).to have_no_content("There was something wrong with your login information")
	end
	
	scenario "with invalid credentials" do
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: 'wrong'
		fill_in "Password", with: 'wrong'
		click_button "Log in"
		
		expect(page).to have_content("There was something wrong with your login information")		
	end
end