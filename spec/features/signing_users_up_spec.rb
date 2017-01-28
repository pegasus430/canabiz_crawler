require "rails_helper"

RSpec.feature "Users Sign Up" do 
	
	before do 
		@user = User.create!(username: "username", password: "password", admin: false)	
	end
	
	scenario "with valid credentials" do 
		visit "/"
		first(:link, "Sign Up").click
		expect(page).to have_content('Sign up for Cannabiz Network')
		
		fill_in "Username", with: 'User'
		fill_in "email", with: 'user@gmail.com'
		fill_in "Password", with: 'Password'
		click_button "Sign Up"
		
		expect(page).to have_content("Welcome to the Cannabiz Network User")
	end
	
	#scenario "with invalid credentials" do
	#	visit "/"
	#	first(:link, "Log In").click #because there is more than one
	#	fill_in "Username", with: 'wrong'
	#	fill_in "Password", with: 'wrong'
	#	click_button "Log in"
		
	#	expect(page).to have_content("There was something wrong with your login information")		
	#end
end