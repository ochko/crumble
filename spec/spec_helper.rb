require 'rubygems'
gem 'rspec'

require "#{File.dirname(__FILE__)}/../lib/crumble"

RSpec.configure do |config|

  config.before(:each) do
    @old_trails = Crumble.instance.trails
    Crumble.instance.trails = nil
  
    @old_crumbs = Crumble.instance.crumbs
    Crumble.instance.crumbs = nil
  end
  
  config.after(:each) do
    Crumble.instance.crumbs = @old_crumbs
    Crumble.instance.trails = @old_trails
  end

  public
  
  def edit_account_url
    "http://test.host/account/edit"
  end
  
  def user_url(user)
    "http://test.host/f/#{user.login}"
  end
  
  def user_article_url(user, article)
    "http://test.host/f/#{user.login}/articles/#{article.id}"
  end
  
  def search_url(params = nil)
    if params.is_a?(Hash)
      "http://test.host/search?#{params.collect{|key, value| "#{key.to_s}=#{value}"}.join('&')}"
    else
      "http://test.host/search/#{params}"
    end
  end
  
  def url_for(params)
    if params.is_a?(Hash)
      "http://test.host/#{params[:controller]}/#{params[:action]}"
    else
      super
    end
  end
  
  def is_it_false?
    false
  end
  
  def its_true!
    true
  end
  
  User = Struct.new(:login)
  Article = Struct.new(:id)
end
