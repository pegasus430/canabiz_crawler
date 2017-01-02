require "rails_helper"

RSpec.feature "Visit Admin Page" do 
	scenario "An admin visits the admin page" do
		visit "/admin"
	end
end