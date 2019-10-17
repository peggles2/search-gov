# frozen_string_literal: true

require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it { is_expected.to use_before_filter(:reset_session) }

  describe '#security_notification' do
    before { get :security_notification }
    it { is_expected.to render_template(:security_notification) }
  end

  describe "#create" do
    let(:user) { users(:affiliate_manager) }
    let(:post_create) do
      post :create,
           params: {
             user_session: {
               email: user.email
             }
           }
    end

    context 'when the user is not approved' do
      let(:user) { users(:affiliate_manager_with_not_approved_status) }
      before { post_create }

      it { is_expected.to redirect_to(login_path) }
    end

    context 'when the user session fails to save' do
      before do
        post :create,
             params: {
               user_session: {
                 email: 'invalid@fixtures.org'
               }
             }
      end

      it { is_expected.to redirect_to(login_path) }
    end
  end

  describe 'do POST on create for developer' do
    # commented out for now but will refactor later for login_dot_gov
    xit 'should redirect to affiliate home page' do
      post :create,
           params: {
             user_session: {
               email: users('developer').email
             }
           }
      expect(response).to redirect_to(developer_redirect_url)
    end
  end
end
