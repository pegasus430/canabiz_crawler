require "rails_helper"

RSpec.feature "Create State" do 
	
	before do 
		@adminUser = User.create(username: "test user", password: "password", admin: true)
	end 
	
	scenario "An admin creates a state" do
		
		#LOGIN AS THE ADMIN
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: @adminUser.username
		fill_in "Password", with: @adminUser.password
		click_button "Log in"
		
		#VISIT ADMIN PAGE
		visit "/admin"
		expect(page).to have_link('States')
		
		click_link "States"
		click_link "Create New State"
		
		fill_in "Name", with: "Test State"
		fill_in "Abbreviation", with: "TS"
		fill_in "Keywords", with: "TS,Test State"
		
		click_button "Create State"
		expect(page).to have_content('State was successfully created')
	end
end