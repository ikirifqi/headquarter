# Signs members in by email. Passwords are not checked while members come from config/dummy.yml.
class SessionsController < InertiaController
  def new
    render inertia: { demo_accounts: Dummy::Members.new(dummy).demo, return_to: return_to_path }
  end

  def create
    email = params[:email].to_s.strip.downcase

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      return redirect_to login_path(return_to: return_to_path), inertia: { errors: { email: t('.invalid_email') } }
    end

    destination = return_to_path
    reset_session
    session[:email] = email
    redirect_to destination || root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def return_to_path
    url_from(params[:return_to])
  end
end
