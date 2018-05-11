class SourcesController < ApplicationController
    
    before_action :set_source, only: [:edit, :update, :destroy, :show] #
    before_action :require_admin, except: [:show]
    
    def show
        if @source.active
            @recents = @source.articles.includes(:source, :categories, :states).
                            order("created_at DESC").page(params[:page]).per_page(24)
            @mostviews = @source.articles.includes(:source, :categories, :states).
                            order("num_views DESC").page(params[:page]).per_page(24)
        else
            redirect_to root_path
        end
    end
  
    private

        def set_source
            @source = Source.friendly.find(params[:id])
        end
end