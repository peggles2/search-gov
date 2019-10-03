# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def login_dot_gov
    auth = request.env['omniauth.auth']
    puts "assigning user".cyan
    @user = User.from_omniauth(auth)
    return unless @user.persisted?

    UserSession.create(@user)
    redirect_to(admin_home_page_path)
  end
end
