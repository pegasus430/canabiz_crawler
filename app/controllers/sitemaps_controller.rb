class SitemapsController < ApplicationController
  def index
    @static_pages = [root_url]
    @products = Product.featured
    @vendors = Vendor.all
    @dispensaries = Dispensary.all
    @articles = Article.all
    @categories = Category.all

    respond_to do |format|
      format.xml
    end
  end
end