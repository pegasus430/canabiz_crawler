class HashtagsController < ApplicationController
    
    before_action :set_hashtag, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show]

    #--------ADMIN PAGE-------------------------
    def admin
        @hashtags = Hashtag.all.order(sort_column + " " + sort_direction)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @hashtags.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        Hashtag.import(params[:file])
        flash[:success] = 'Hashtags were successfully imported'
        redirect_to hashtag_admin_path 
    end
    
    def search
        @q = "%#{params[:query]}%"
        @categories = Category.where("name LIKE ? or keywords LIKE ?", @q, @q).order(sort_column + " " + 
                                    sort_direction).paginate(page: params[:page], per_page: 50)
        render 'admin'
    end
    #--------ADMIN PAGE-------------------------
    
    #-------------------------------------------
    def new
      @hashtag = Hashtag.new
    end
    def create
        
        @hashtag = Hashtag.new(hashtag_params)
        if @hashtag.save
            flash[:success] = 'Hashtag was successfully created'
            redirect_to hashtag_admin_path
        else 
            render 'new'
        end
    end
    
    #-------------------------------------------
    
    def show
        
    end

    #-------------------------------------------
    
    def edit
    end   
    def update
        if @hashtag.update(hashtag_params)
            flash[:success] = 'Hashtag was successfully updated'
            redirect_to hashtag_admin_path
        else 
            render 'edit'
        end
    end 
    
    #-------------------------------------------
   
    def destroy
        @category.destroy
        flash[:success] = 'Category was successfully deleted'
        redirect_to category_admin_path
    end
   
    def destroy_multiple
        Hashtag.destroy(params[:hashtags])
        flash[:success] = 'Hashtags were successfully deleted'
        redirect_to hashtag_admin_path        
    end
    
    #-------------------------------------------

  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_hashtag
          @hashtag = Hashtag.find(params[:id])
        end
        
        def hashtag_params
          params.require(:hashtag).permit(:name, source_ids: [])
        end  
        
        def sort_column
            params[:sort] || "name"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
end