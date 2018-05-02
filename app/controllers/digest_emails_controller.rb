class DigestEmailsController < ApplicationController
    
    before_action :set_digest_email, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :show, :admin]
    
    #-------------------------------------------
    def new
      @digest_email = DigestEmail.new
    end
    def create
        #render plain: params[:category].inspect
        @digest_email = DigestEmail.new(digest_email_params)
        if @category.save
            flash[:success] = 'Email was successfully created'
            redirect_to digest_emails_admin_path
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
        if @digest_email.update(digest_email_params)
            flash[:success] = 'Email was successfully updated'
            redirect_to digest_emails_admin_path
        else 
            render 'edit'
        end
    end 
    
    #-------------------------------------------
   
    def destroy
        @digest_email.destroy
        flash[:success] = 'Email was successfully deleted'
        redirect_to digest_emails_admin_path
    end
   
    def destroy_multiple
        DigestEmail.destroy(params[:digest_emails])
        flash[:success] = 'Emails were successfully deleted'
        redirect_to digest_emails_admin_path        
    end
    
    #-------------------------------------------

  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_digest_email
          @digest_email = DigestEmail.find(params[:id])
        end
        
        def digest_email_params
          params.require(:digest_email).permit(:email, :active)
        end  
        
        def sort_column
            params[:sort] || "email"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
end