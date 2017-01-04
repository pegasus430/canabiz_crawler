require "rails_helper"

RSpec.feature "Visit Admin Page" do 
	
	#create admin user
	before do 
		@adminUser = User.create(username: "test user", password: "password", admin: true)
		@nonadminUser = User.create(username: "non admin", password: 'password', admin: false)
	end 
	
	scenario "An admin visits the admin page" do
		
		#login as admin
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: @adminUser.username
		fill_in "Password", with: @adminUser.password
		click_button "Log in"
		
		visit "/admin"
		expect(page).to have_link('Categories')
	end
	
	scenario "A non-admin visits the admin page" do
		
		#notlogged in
		visit "/admin"
		expect(page).to have_no_link('Categories')
		
		#login as non-admin
		visit "/"
		first(:link, "Log In").click #because there is more than one
		fill_in "Username", with: @nonadminUser.username
		fill_in "Password", with: @nonadminUser.password
		click_button "Log in"
		
		visit "/admin"
		expect(page).to have_no_link('Categories')
	end
end