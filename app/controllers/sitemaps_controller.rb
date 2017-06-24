class SitemapsController < ApplicationController
  def index
    @static_pages = [root_url]

    @articles = Article.all

    respond_to do |format|
      format.xml
    end
  end
end