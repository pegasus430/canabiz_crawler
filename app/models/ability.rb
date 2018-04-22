class Ability
  include CanCan::Ability
  include ActiveAdminRole::CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    if user.super_user?
      can :manage, :all
    elsif user.dispensary_admin_user?
      can :manage, AdminUser
      can :manage, Dispensary, :admin_user_id => user.id
      cannot [:destroy, :create], Dispensary
      can :manage, DispensarySource, {dispensary: {admin_user_id: user.id}}
      can :manage, DispensarySourceProduct, {dispensary_source: {dispensary: {admin_user_id: user.id}}}
      # can :manage, DspPrice, {dispensary_source_product: {dispensary_source: {dispensary: {admin_user_id: user.id}}}}
      can :read, Product
    end

    # NOTE: Everyone can read the page of Permission Deny
    can :read, ActiveAdmin::Page, name: "Dashboard"
  end
end