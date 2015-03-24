class ApplicationController < ActionController::Base
  include ::SslRequirement
  skip_before_filter :ensure_proper_protocol unless Rails.env.production?
  before_filter :set_default_locale
  before_filter :show_searchbox
  helper :all
  helper_method :current_user_session, :current_user
  protect_from_forgery
  VALID_FORMATS = %w{html rss json xml mobile}
  SERP_RESULTS_PER_PAGE = 20

  rescue_from ActionView::MissingTemplate, :with => :template_not_found

  protected

  def set_affiliate
    @affiliate = Affiliate.find_by_name(params[:affiliate].to_s) unless params[:affiliate].blank?

    unless @affiliate
      redirect_to('http://www.usa.gov/page-not-found') and return
    end
  end

  def set_header_footer_fields
    if @affiliate && params['staged']
      @affiliate.nested_header_footer_css = @affiliate.staged_nested_header_footer_css
      @affiliate.header = @affiliate.staged_header
      @affiliate.footer = @affiliate.staged_footer
      @affiliate.uses_managed_header_footer = @affiliate.staged_uses_managed_header_footer
    end

    @affiliate.use_strictui if params[:strictui]
  end

  def set_locale_based_on_affiliate_locale
    I18n.locale = @affiliate.locale.to_sym
  end

  private

  def template_not_found(error)
    if VALID_FORMATS.include?(request.format)
      raise error
    else
      render text: '406 Not Acceptable', status: 406
    end
  end

  def set_default_locale
    I18n.locale = :en
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      redirect_to login_url
      false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to account_url
      false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def show_searchbox
    @show_searchbox = params[:show_searchbox].present? && params[:show_searchbox] == "false" ? false : true
  end

  def search_options_from_params(affiliate, params)
    params.reject!{|k,v| params[k].instance_of? Array}
    {
      :affiliate => affiliate,
      :page => params[:page],
      :per_page => SERP_RESULTS_PER_PAGE,
      :query => sanitize_query(params["query"]),
      :query_quote => sanitize_query(params["query-quote"]),
      :query_or => sanitize_query(params["query-or"]),
      :query_not => sanitize_query(params["query-not"]),
      :file_type => params["filetype"],
      :site_limits => params["sitelimit"],
      :site_excludes => params["siteexclude"],
      :filter => params["filter"],
      :enable_highlighting => params["hl"].present? && params["hl"] == "false" ? false : true,
      :dc => params["dc"],
      :channel => params["channel"],
      :tbs => params["tbs"]
    }
  end

  def sanitize_query(query)
    QuerySanitizer.sanitize(query)
  end

  def force_request_format
    return if request.format && request.format.json?

    if @affiliate.force_mobile_format? || params[:m] == 'true'
      request.format = :mobile
    elsif params[:m] == 'false' or params[:m] == 'override'
      request.format = :html
    end
  end

  def set_search_params
    @search_params = { query: @search.query, affiliate: @affiliate.name }
    @search_params.merge!(sitelimit: params[:sitelimit]) if params[:sitelimit].present?
    if @search.is_a?(NewsSearch)
      @search_params.merge!(channel: @search.rss_feed.id) if @search.rss_feed
      @search_params.merge!(tbs: params[:tbs]) if params[:since_date].blank? and params[:until_date].blank? and params[:tbs]
      @search_params.merge!(since_date: @search.since.strftime(I18n.t(:cdr_format))) if params[:since_date].present? && @search.since
      @search_params.merge!(until_date: @search.until.strftime(I18n.t(:cdr_format))) if params[:until_date].present? && @search.until
      @search_params.merge!(sort_by: params[:sort_by]) if params[:sort_by]
      @search_params.merge!(contributor: params[:contributor]) if params[:contributor]
      @search_params.merge!(publisher: params[:publisher]) if params[:publisher]
      @search_params.merge!(subject: params[:subject]) if params[:subject]
    end
  end

  def set_search_page_title
    query_string = @page_title.blank? ? '' : @page_title
    @page_title = I18n.t(:default_serp_title,
                         query: query_string,
                         site_name: @affiliate.display_name)
  end
end
