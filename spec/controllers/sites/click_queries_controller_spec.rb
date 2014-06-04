require 'spec_helper'

describe Sites::ClickQueriesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#show?rtu=true' do
    it_should_behave_like 'restricted to approved user', :get, :show

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'
      let(:top_n) { [['query1', 10], ['query2', 5]] }
      let(:rtu_top_clicks) { mock(RtuTopClicks, top_n: top_n) }

      before do
        RtuTopClicks.stub(:new).and_return rtu_top_clicks
        get :show, id: site.id, start_date: Date.current, end_date: Date.current, url: 'http://www.url.gov', rtu: true
      end

      it { should assign_to(:top_queries).with(top_n) }
    end
  end

end