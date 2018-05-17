class BlogController < ApplicationController
    before_action :set_blog, only: [:show]
    
    def show
        
    end
    
    def index
       @blogs = Blog.order("created_at DESC") 
    end

    private 
        
        def set_blog
            @blog = Blog.friendly.find(params[:id])
            if @blog.blank?
                redirect_to root_path 
            end
        end
end