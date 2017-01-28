class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :update, :show]
    before_action :require_same_user, only: [:edit, :update, :destroy, :show]
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
  
    def show
        #show the saved articles
        @recents = user.articles.where(saved: true)
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