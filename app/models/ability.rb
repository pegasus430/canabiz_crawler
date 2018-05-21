class Ability
  include CanCan::Ability
  include ActiveAdminRole::CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    if user.super_user?
      can :manage, :all
      
    elsif user.dispensary_admin_user?
      can :read, Product
      can :manage, AdminUser, :id => user.id
      cannot [:destroy], AdminUser
      # can :manage, DispensarySourceProduct, :dispensary_source_id => user.dispensary_source.id
      can :manage, DispensarySourceProduct
      

      can :manage, DispensarySource, :admin_user_id => user.id
      cannot [:destroy], DispensarySource
      
      can [:manage, :read], DispensarySourceOrder, {dispensary_source: {admin_user_id: user.id}}
      cannot [:destroy, :create], DispensarySourceOrder
      
      can :manage, DispensarySourceProduct, {dispensary_source: {admin_user_id: user.id}}
      can :manage, DspPrice, {dispensary_source_product: {dispensary_source: {dispensary: {admin_user_id: user.id}}}}
      
    end

    # NOTE: Everyone can read the page of Permission Deny
    can :read, ActiveAdmin::Page, name: "Dashboard"
  end
end