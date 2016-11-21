class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :show]
    

    def admin
        @states = State.all
        
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
        
                    
        #sort by the option selected by user
        if params[:option] != nil
            @sort_option = SortOption.find(params[:option])
            
            if @sort_option != nil
                #add a click to the sort option
                @sort_option.increment(:num_clicks, by = 1)
                @sort_option.save
                
                @articles = @state.articles.order(@sort_option.query + " " + @sort_option.direction).page(params[:page]).per_page(24)
            else 
                @articles = @state.articles.order("created_at DESC").page(params[:page])    
            end
        else 
            @articles = @state.articles.order("created_at DESC").page(params[:page])
        end 
        
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
         @state = State.find(params[:id])
      end
      def state_params
        params.require(:state).permit(:name, :abbreviation, :timezone_id, :keywords, :logo)
      end    
    
end