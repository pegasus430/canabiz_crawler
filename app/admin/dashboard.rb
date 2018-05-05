ActiveAdmin.register_page "Dashboard" do

    menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
    
    content title: proc{ I18n.t("active_admin.dashboard") } do
        section 'Recent Orders' do
        
            if current_admin_user.admin?
                table_for Order.order('created_at DESC').limit(5) do
                    column :name
                    column 'Address' do |order|
                	    order.address
    				end
                	column 'Phone' do |order|
                        order.phone
    				end
                    column :total_price do |order|
                        number_to_currency order.total_price
                    end
                    column :created_at do |order|
                        time_ago_in_words order.created_at
                    end
                end 
                strong {link_to 'View All Orders', admin_orders_path}
            end
            
            if current_admin_user.dispensary_admin_user?
                table_for DispensarySourceOrder.order('created_at DESC').limit(5) do
                    column "Name" do |dso|
        				if dso.order.present?
        					dso.order.name
        				end
        			end
                	column 'Address' do |dso|
                	    if dso.order.present?
    					    dso.order.address
    				    end
    				end
                	column 'Phone' do |dso|
                	    if dso.order.present?
    					    dso.order.phone
    				    end
    				end
                    column :total_price do |dso|
                        number_to_currency dso.total_price
                    end
                    column 'Created At' do |dso|
    					"#{time_ago_in_words dso.created_at} ago"
    				end
                	column 'Delivered' do |dso|
    					dso.delivered
    				end
    				column 'Picked Up' do |dso|
    					dso.picked_up
    				end
                    
                end 
                strong {link_to 'View All Orders', admin_orders_path}
            end            
        end
    end # content
end