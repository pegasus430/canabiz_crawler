class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :show]
    

    def index
    end

    def admin
        @states = State.all.order("name ASC")
        
        #method is used for csv file upload
        def import
            State.import(params[:file])
            flash[:success] = 'States were successfully imported'
            redirect_to states_admin_path 
        end        
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @states.to_csv }
        end
    end
    
    def new
      @state = State.new
    end
    
    def create
      @state = State.new(state_params)
      if @state.save
         flash[:success] = 'State was successfully created'
         redirect_to states_admin_path
      else 
         render 'new'
      end
    end 
    
    def show
        source_ids = @sources.pluck(:id)
        @recents = @state.articles.where("source_id IN (?)", source_ids).
                            includes(:source).includes(:categories).includes(:states).
                            order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
        @mostviews = @state.articles.where("source_id IN (?)", source_ids).
                            includes(:source).includes(:categories).includes(:states).
                            order("num_views DESC").paginate(:page => params[:page], :per_page => 24) 
                            
        expires_in 10.minutes, :public => true
    end
    
   def edit
   end   
   
   def update
      if @state.update(state_params)
         flash[:success] = 'State was successfully updated'
         redirect_to states_admin_path
      else 
         render 'edit'
      end
   end 
   
   def destroy
      @state.destroy
      flash[:success] = 'State was successfully deleted'
      redirect_to states_admin_path
   end    
    
    private 
      def set_state
         @state = State.friendly.find(params[:id])
      end
      def state_params
        params.require(:state).permit(:name, :abbreviation, :timezone_id, :keywords, :logo, :slug)
      end    
    
end