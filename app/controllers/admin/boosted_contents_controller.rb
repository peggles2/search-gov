class Admin::BoostedContentsController < Admin::AdminController
  active_scaffold :boosted_content do |config|
    config.columns = [:description, :title, :url, :locale]
    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = {:options => SUPPORTED_LOCALES.map{|locale| [locale.to_sym, locale]}}
  end

  def after_create_save(boosted_content)
    Sunspot.index(boosted_content)
  end

  def after_update_save(boosted_content)
    Sunspot.index(boosted_content)
  end
end
