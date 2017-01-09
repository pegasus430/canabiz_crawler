require "rails_helper" 

RSpec.feature "View State News" do
	before do
		@source1 = Source.create(name: "Test Source")
		@state = State.create(name: "Test State", abbreviation: 'TS')
		
		@article1 = Article.create(title: "The first article",
		body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id)
		
		@article_state = ArticleState.create(article_id: @article1.id, state_id: @state.id)

		@article2 = Article.create(title: "The second article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source1.id)
		
	end	
	
	scenario "user visits state news page" do

		visit "/"
		visit "/states/#{@state.id}"
		
		expect(page).to have_content(@article1.title) 
		expect(page).to have_no_content(@article2.title) 
	end
end