require "rails_helper" 

RSpec.feature "Home Page Articles" do
	before do
		@source1 = Source.create(name: "Test Source")
		@source2 = Source.create(name: "Test Source 2")
		@source3 = Source.create(name: "Test Source 3")
		
		@article1 = Article.create(title: "The first article",
		body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id) 

		@article2 = Article.create(title: "The second article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source2.id)
		
		@article3 = Article.create(title: "The third article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source3.id)
		
		@article3 = Article.create(title: "The fourth article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source3.id)		
	end	
	
	scenario "articles listed on home page" do

		visit "/"
		#expect(page).to have_content(@article1.title) 
		#expect(page).to have_content(@article1.source.name) 
		#expect(page).to have_content(@article2.title) 
		#expect(page).to have_content(@article2.source.name) 
		#expect(page).to have_link(@article1.source.name) 
		#expect(page).to have_link(@article2.title)
	end
end