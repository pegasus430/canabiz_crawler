ActiveAdmin.register Vendor do
	menu :if => proc{ current_admin_user.admin? }
end
