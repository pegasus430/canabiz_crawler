require "rails_helper"

RSpec.feature "Create Category" do 
	
	before do 
		@adminUser = User.create(username: "test user", password: "password", admin: true)
	end 
	
	scenario "An admin creates a category" do
		login_as(@adminUser)
		visit "/admin"
		expect(page).to have_link('Categories')
		
		#click_link "Categories"
		#click_link "Create New Category"
		
		#fill_in "Name", with: "Test Category"
		#fill_in "Keywords", with: "Test,Category"
		#fill_in "Active", with: true
		
		#click_button "Create Category"
	end
end