ActiveAdmin.register Deal do
    
    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :dispensary_id, :name, :discount, :deal_type, :top_deal, :min_age, :image
	
	#save queries
	includes :dispensary
	
	index do
		selectable_column
		column :name
		column "Dispensary" do |deal|
			if deal.dispensary.present?
				link_to deal.dispensary.product.name, admin_dispensary_path(deal.dispensary)
			end
		end
		column "Image" do |deal|
          truncate(deal.image_url, omision: "...", length: 50) if deal.image
        end
		column :discount
		column :deal_type
		column :top_deal
		column :min_age
		column :updated_at
		actions
	end

	form(:html => { :multipart => true }) do |f|
		f.input :name
		f.input :image, :as => :file
		f.input :dispensary_id, :label => 'Dispensary', :as => :select, 
				:collection => Dispensary.all.map{|u| ["#{u.name}", u.id]}
		f.input :discount
		f.input :deal_type
		f.input :top_deal
		f.input :min_age
    	f.actions
    end

end
