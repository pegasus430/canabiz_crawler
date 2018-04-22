class AdminUser < ActiveRecord::Base
  role_based_authorizable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
  
  has_one :dispensary
  has_one :dispensary_source
  
  def dispensary_admin_user?
    self.role == 'dispensary_admin'
  end

  def admin?
    self.role == 'admin'
  end
end