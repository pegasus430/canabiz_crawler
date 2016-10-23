class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :deals, :dispensaries]
    
    def news
        if params[:id].present?
            @state = State.find(params[:id])
            @top_articles = @state.articles.where('image IS NOT NULL').limit(3).order("RANDOM()")
            @second_articles = @state.articles.where('image IS NOT NULL').limit(4).order("RANDOM()")
        else
            @top_articles = Article.all
            @second_articles = Article.all
        end
        @categories = Category.order("RANDOM()").where(:active =>  true).limit(5)
            
        #@teams = Team.where("name NOT IN (?)", @team_exclude_list)
        # This set up will make it so i don't query the same articles in the second list
        # need to first do a for loop that puts all of the names into an array and then do this        
    end
    
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
        params.require(:state).permit(:name, :abbreviation, :timezone_id, :keywords)
      end    
    
end