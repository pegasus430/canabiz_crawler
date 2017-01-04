require "rails_helper"

RSpec.feature "Create Source" do 
	
	before do 
		@adminUser = User.create(username: "test user", password: "password", admin: true)
	end 
	
	scenario "An admin creates a source" do
		
		#LOGIN AS THE ADMIN
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: @adminUser.username
		fill_in "Password", with: @adminUser.password
		click_button "Log in"
		
		#VISIT ADMIN PAGE
		visit "/admin"
		expect(page).to have_link('Sources')
		
		click_link "Sources"
		click_link "Create New Source"
		
		fill_in "Name", with: "Test Source"
		fill_in "Homepage Url", with: "https://source.com"
		
		click_button "Create Source"
		expect(page).to have_content('Source was successfully created')
	end
end