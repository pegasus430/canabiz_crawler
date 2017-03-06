class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :update, :show, :change_password]
    before_action :require_same_user, only: [:edit, :update, :destroy, :show, :change_password]
    #before_action :require_admin, only: [:destroy]
  
  
    def admin
        @users = User.paginate(page: params[:page], per_page: 100)
        
        #method is used for csv file upload
        def import
            State.import(params[:file])
            flash[:success] = 'Users were successfully imported'
            redirect_to users_admin_path 
        end        
        
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @users.to_csv }
        end
    end  
  
    def search
        @q = "%#{params[:query]}%"
        @users = User.where("username LIKE ? or email LIKE ?", @q, @q).order(sort_column + " " + sort_direction)
        
        render 'admin'
    end
  
    def new
        @user = User.new
    end
  
    def create
        @user = User.new(user_params)
        if @user.save
            session[:user_id] = @user.id
            flash[:success] = "Welcome to the Cannabiz Network #{@user.username}"
            redirect_to root_path(@user)
        else
            render 'new'
        end
    end
  
    def edit
    end
  
    def update
        if @user.update(user_params)
            flash[:success] = "Your settings were saved successfully"
            redirect_to user_path(@user)
        else
            render 'edit'
        end
    end
    
    def change_password
    end
    
    def submit_password_change
        @user = User.find(params[:user_id])
        logger.info @user
        logger.info current_user
        if @user == current_user
            #&& params[:old_password] != nil && params[:new_password] != nil && params[:confirm_password] != nil

            if @user.authenticate(params[:old_password])
            #if @user.password == params[:old_password]
                
                if params[:new_password] == params[:confirm_password]
                    @user.update_attribute(:password, params[:new_password])
                    flash[:success] = 'Password Changed'
                    #redirect_to root_path
                else 
                    flash.now[:danger] = 'Passwords do not Match'
                    render 'change_password'
                end
            else 
               flash.now[:danger] = 'Old Password is Incorrect'
               render 'change_password'
            end
            
            
        else
            flash.now[:danger] = 'Missing a parameter'
            render 'change_password'
            #redirect_to root_path
        end
    end 
    
    def other

    end     
  
    def show
        #my feed articles
         @recents = Article.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
            
        if current_user.sources.any?
             @recents = @recents.where(source_id: current_user.sources)
        end
        
        if current_user.states.any?
            #add a where clause to only be user states
            state_ids = current_user.states.pluck(:id)
            article_ids = ArticleState.where(state_id: state_ids).pluck(:article_id)
            @recents = @recents.where(id: article_ids)
        end
        
        if current_user.categories.any?
           #add a where clause to only be user categories
            category_ids = current_user.categories.pluck(:id)
            article_ids = ArticleCategory.where(category_id: category_ids).pluck(:article_id)
            @recents = @recents.where(id: article_ids)
        end
       
        #saved articles
        article_ids = UserArticle.where(:user_id => current_user.id, :saved => true).pluck(:article_id)
        @savedArticles = Article.where(id: article_ids)
        
        #trending articles for sidebar
        @trendingArticles = Article.order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
    end
  
    def destroy
        @user = User.find(params[:id])
        @user.destroy
        flash[:danger] = "User has been deleted"
        redirect_to users_admin_path
    end
  
    private
    
        def user_params
            params.require(:user).permit(:username, :email, :password, state_ids: [], category_ids: [], source_ids: [])
        end
        
        def set_user
            @user = User.friendly.find(params[:id]) 
        end
        
        def require_same_user
            if current_user != @user
                flash[:danger] = "You can only edit your own account"
                redirect_to root_path
            end
        end
        
        def require_admin
            if logged_in? and !current_user.admin?
                flash[:danger] = "Only admin users can perform that action"
                redirect_to root_path
            end
        end
  
end