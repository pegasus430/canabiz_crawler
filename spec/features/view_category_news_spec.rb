require "rails_helper" 

RSpec.feature "View Category News" do
	before do
		@source1 = Source.create(name: "Test Source")
		@category = Category.create(name: "Test Category")
		
		@article1 = Article.create(title: "The first article",
		body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id)
		
		@article_category = ArticleCategory.create(article_id: @article1.id, category_id: @category.id)

		@article2 = Article.create(title: "The second article",
		body: "Pellentesque ac ligula in tellus feugiat.", source_id: @source1.id)
		
	end	
	
	scenario "user visits category news page" do

		visit "/"
		visit "/categories/#{@category.id}"
		
		expect(page).to have_content(@article1.title) 
		expect(page).to have_no_content(@article2.title) 
	end
end