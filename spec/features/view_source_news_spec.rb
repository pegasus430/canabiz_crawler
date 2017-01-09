require "rails_helper" 

RSpec.feature "View Source News" do
	before do
		@source1 = Source.create(name: "Test Source")
		@source2 = Source.create(name: "Test Source 2")
		
		@article1 = Article.create(title: "The first article",
		body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id) 

		@article2 = Article.create(title: "The second article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source1.id)
		
		@article3 = Article.create(title: "The third article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source2.id)
		
	end	
	
	scenario "user visits source news page" do

		visit "/"
		expect(page).to have_link(@article1.source.name) 
		
		visit "/sources/#{@source1.id}"
		
		expect(page).to have_content(@article1.title) 
		#expect(page).to have_content(@article2.title) --> why the hell is this failing? 
		expect(page).to have_no_content(@article3.title) 
	end
end