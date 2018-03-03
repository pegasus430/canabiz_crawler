class DispensarySourcesController < ApplicationController
    
    before_action :set_dispensary_source, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show]

    #--------ADMIN PAGE-------------------------
    def admin
        @dispensary_sources = DispensarySource.order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: 50)
    
        respond_to do |format|
            format.html
            format.csv {render text: @dispensary_sources.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        DispensarySource.import(params[:file])
        flash[:success] = 'Dispensary Sources were successfully imported'
        redirect_to dispensary_sources_admin_path 
    end
    
    #--------ADMIN PAGE-------------------------
    
    #-----------------------------------
    def new
      @dispensary_source = DispensarySource.new
    end
    def create
      @dispensary_source = DispensarySource.new(dispensary_source_params)
      if @dispensary_source.save
         flash[:success] = 'Dispensary Source was successfully created'
         redirect_to dispensary_sources_admin_path
      else 
         render 'new'
      end
    end 
    #-------------------------------------

    def show
    end
    
    #-------------------------------------    
    def edit
    end   
    def update
        if @dispensary_source.update(dispensary_source_params)
            flash[:success] = 'Dispensary Source was successfully updated'
            redirect_to dispensary_sources_admin_path
        else 
            render 'edit'
        end
    end
    #-------------------------------------
   
    def destroy
        @dispensary_source.destroy
        flash[:success] = 'Dispensary Source was successfully deleted'
        redirect_to dispensary_sources_admin_path
    end  
    
    def destroy_multiple
      DispensarySource.destroy(params[:dispensary_sources])
      flash[:success] = 'Dispensary Sources were successfully deleted'
      redirect_to dispensary_sources_admin_path        
    end 
    
    #-------------------------------------
    private 
        
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        def set_dispensary_source
            @dispensary_source = DispensarySource.find(params[:id])
        end
        
        def dispensary_source_params
            params.require(:dispensary_source).permit(:dispensary_id, :source_id, :state_id, :name, :slug, :image, 
                                                            :location, :city, :street, :zip_code, :latitude, :remote_image_url,
                                                            :longitude, :source_rating, 
                                                            :source_url, :monday_open_time, :tuesday_open_time, 
                                                            :wednesday_open_time, :thursday_open_time, 
                                                            :friday_open_time, :saturday_open_time, :sunday_open_time, 
                                                            :monday_close_time, :tuesday_close_time, :wednesday_close_time, 
                                                            :thursday_close_time, :friday_close_time, :saturday_close_time, 
                                                            :sunday_close_time, :facebook, :instagram, :twitter, :website, 
                                                            :email, :phone, :min_age)
        end
        
        def sort_column
            params[:sort] || "dispensary_id"
        end
        def sort_direction
            params[:direction] || 'desc'
        end 
end