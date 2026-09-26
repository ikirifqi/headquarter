# Base for every page: shares the organization and the signed-in member with each Inertia response
class InertiaController < ApplicationController
  inertia_share do
    {
      organization: dummy[:organization].slice(:name, :today),
      current_user: current_user_props
    }
  end

  private

  def dummy
    @dummy ||= Dummy.data
  end

  def current_member
    return @current_member if defined?(@current_member)

    @current_member = session[:email] && Dummy::Members.new(dummy).find_or_guest(session[:email])
  end

  def admin?
    current_member&.dig(:role) == 'admin'
  end

  def current_user_props
    return unless current_member

    current_member.slice(:name, :email, :role).merge(
      first_name: current_member[:name].sub(/\A.*— /, '').split.first
    )
  end
end
