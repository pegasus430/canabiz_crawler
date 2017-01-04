require "rails_helper"

RSpec.feature "Create Category" do 
	
	before do 
		@adminUser = User.create(username: "test user", password: "password", admin: true)
	end 
	
	scenario "An admin creates a category" do
		
		#LOGIN AS THE ADMIN
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: @adminUser.username
		fill_in "Password", with: @adminUser.password
		click_button "Log in"
		
		#VISIT ADMIN PAGE
		visit "/admin"
		expect(page).to have_link('Categories')
		
		click_link "Categories"
		click_link "Create New Category"
		
		fill_in "Name", with: "Test Category"
		fill_in "Keywords", with: "Test,Category"
		#check "Active"
		#fill_in "Active", with: true
		
		click_button "Create Category"
		expect(page).to have_content('Category was successfully created')
	end
end