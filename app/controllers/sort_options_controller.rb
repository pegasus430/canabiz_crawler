class SortOptionsController < ApplicationController
    
    before_action :set_sort_option, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show]

    #--------ADMIN PAGE-------------------------
    def admin
        @sort_options = SortOption.all.order(sort_column + " " + sort_direction)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @sort_options.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        SortOption.import(params[:file])
        flash[:success] = 'Sort Options were successfully imported'
        redirect_to sort_options_admin_path 
    end
    
    def search
        @q = "%#{params[:query]}%"
        #@categories = Category.where("name LIKE ? or keywords LIKE ?", @q, @q).order(sort_column + " " + 
         #                           sort_direction).paginate(page: params[:page], per_page: 50)
        render 'admin'
    end
    #--------ADMIN PAGE-------------------------
    
    #-------------------------------------------
    def new
      @sort_option = SortOption.new
    end
    def create
        
        @sort_option = SortOption.new(sort_options_params)
        if @sort_option.save
            flash[:success] = 'Sort Option was successfully created'
            redirect_to sort_options_admin_path
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
        if @sort_option.update(sort_options_params)
            flash[:success] = 'Sort Option was successfully updated'
            redirect_to sort_options_admin_path
        else 
            render 'edit'
        end
    end 
    
    #-------------------------------------------
   
    def destroy
        @sort_option.destroy
        flash[:success] = 'Sort Option was successfully deleted'
        redirect_to sort_options_admin_path
    end
   
    def destroy_multiple
        SortOption.destroy(params[:sort_options])
        flash[:success] = 'Sort Options were successfully deleted'
        redirect_to sort_options_admin_path        
    end
    
    #-------------------------------------------

  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_sort_option
          @sort_option = SortOptions.find(params[:id])
        end
        
        def sort_options_params
          params.require(:sort_option).permit(:name, :direction, :query, :num_clicks)
        end  
        
        def sort_column
            params[:sort] || "name"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
end