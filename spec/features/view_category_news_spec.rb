require "rails_helper" 

RSpec.feature "View Category News" do
	before do
		@source1 = Source.create(name: "Test Source")
		@category = Category.create(name: "Test Category")
		
		@article1 = Article.create(title: "The first article", body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id, web_url: 'source.com/1')
		@article_category = ArticleCategory.create(article_id: @article1.id, category_id: @category.id)

		@article2 = Article.create(title: "The second article", body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id, web_url: 'source.com/2')
		@article_category = ArticleCategory.create(article_id: @article2.id, category_id: @category.id)

		@article3 = Article.create(title: "The third article", body: "Lorem ipsum dolor sit amet, consectetur.", source_id: @source1.id, web_url: 'source.com/3')
	end	
	
	scenario "user visits category news page" do
		
		#make sure all data was created
		expect(Article.where(id: @article1.id, title: @article1.title)).to exist
		expect(Article.where(id: @article2.id, title: @article2.title)).to exist

		visit "/"
		visit "/categories/#{@category.id}"
		
		expect(page).to have_content(@article1.title) 
		expect(page).to have_content(@article2.title) 
		expect(page).to have_no_content(@article3.title) 
	end
end