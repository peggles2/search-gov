class UserSessionsController < ApplicationController
  before_action :reset_session, only: [:destroy]
  before_action :require_user, only: :destroy

  def security_notification; end

  def create
    construct_user_session(user_session_params)

    if @user_session.save
      redirect_back_or_default redirection_path
    else
      redirect_to(login_path)
    end
  end

  def destroy
    current_user_session.destroy
    redirect_back_or_default login_url
  end

  private

  def construct_user_session(params = nil)
    @user_session =
      case params
      when nil
        UserSession.new
      else
        UserSession.new(params)
      end
    @user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end
end

