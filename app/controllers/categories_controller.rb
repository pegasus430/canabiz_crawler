class CategoriesController < ApplicationController
    
    before_action :set_category, only: [:edit, :update, :destroy, :show]
    #before_action :require_admin, except: [:show]

    #--------ADMIN PAGE-------------------------
    def admin
        @categories = Category.all.order(sort_column + " " + sort_direction)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @categories.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        Category.import(params[:file])
        flash[:success] = 'Categories were successfully imported'
        redirect_to category_admin_path 
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
      @category = Category.new
    end
    def create
        #render plain: params[:category].inspect
        @category = Category.new(category_params)
        if @category.save
            flash[:success] = 'Category was successfully created'
            redirect_to category_admin_path
        else 
            render 'new'
        end
    end
    
    #-------------------------------------------
    
    def show
        @articles = @category.articles.order("created_at DESC")
    end

    #-------------------------------------------
    
    def edit
    end   
    def update
        if @category.update(category_params)
            flash[:success] = 'Category was successfully updated'
            redirect_to category_admin_path
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
        Category.destroy(params[:categories])
        flash[:success] = 'Categories were successfully deleted'
        redirect_to category_admin_path        
    end
    
    #-------------------------------------------

  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_category
          @category = Category.find(params[:id])
        end
        
        def category_params
          params.require(:category).permit(:name, :keywords, :active, :category_type)
        end  
        
        def sort_column
            params[:sort] || "name"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
end