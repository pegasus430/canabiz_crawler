ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, :role

  menu priority: 2, :if => proc{ current_admin_user.admin? }
  #menu priority: 2

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :role
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  # || f.object.new_record? - how to tell if it is a new record or not

  form do |f|
    f.inputs do
      if current_admin_user.admin?
        f.input :role
      end
      f.input :email
      if current_admin_user.id.to_i == params[:id].to_i || f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end

end