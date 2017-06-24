base_url = "http://#{request.host_with_port}"
xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  xml.url{
      xml.loc("https://www.cannabiznetwork.com")
      xml.changefreq("daily")
      xml.priority(1.0)
  }
  @articles.each do |article|
    xml.url {
      xml.loc "#{article_url(article)}"
      xml.lastmod article.updated_at.strftime("%F")
      xml.priority(0.5)
    }
  end
end