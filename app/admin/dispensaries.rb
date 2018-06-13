ActiveAdmin.register Dispensary do
    permit_params :name, :state_id, :has_hypur, :has_payqwick
    
    menu priority: 3
  
    #use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@dispensary = Dispensary.friendly.find(params[:id])
    end
    
    #save queries
	includes :state
	
	#filters
	filter :name
    filter :"state_id" , :as => :select, :collection => State.all.map{|u| [u.name , u.id]}
	
	#-----CSV ACTIONS ----------#
    
    #import csv
	action_item only: :index do
		if current_admin_user.admin?
			link_to 'Import Dispensaries', admin_dispensaries_import_dispensaries_path, class: 'import_csv'
		end
	end
	
	#export csv
	csv do
		column :name
		column :state_id
		column "State" do |dispensary|
			if dispensary.state.present?
				dispensary.state.name
			end
		end
		column :has_hypur
		column :has_payqwick
	end
	
	collection_action :import_dispensaries do
		if request.method == "POST"
			if params[:dispensary][:file_name].present?
				file_data = params[:dispensary][:file_name]
				if file_data.respond_to?(:read)
					dispensaries = file_data.read
					Dispensary.import_from_csv(dispensaries)
					flash[:notice] = "Dispensaries imported successfully."
				elsif file_data.respond_to?(:path)
					dispensaries = File.read(file_data.path)
					Dispensary.import_from_csv(dispensaries)
					flash[:notice] = "Dispensaries imported successfully."
				end
			end
			redirect_to admin_dispensaries_path
		end
	end	
	
	#-----CSV ACTIONS ----------#

    index do
        column :name
        column "State", :sortable=>:"states.name" do |dispensary|
			if dispensary.state.present?
				link_to dispensary.state.name, admin_state_path(dispensary.state)
			end
		end
        column :has_hypur
        column :has_payqwick
        column :updated_at
        actions
    end
  
    form do |f|
        f.inputs "Dispensary" do
            f.input :name
            f.input :state_id, :label => 'State', :as => :select, 
                :collection => State.all.map{|u| ["#{u.name}", u.id]}
            f.input :has_hypur
            f.input :has_payqwick
        end
        f.actions
    end

end
