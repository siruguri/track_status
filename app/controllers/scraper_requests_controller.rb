class ScraperRequestsController < ApplicationController
  before_action :check_params, only: [:create]
  
  def new
    @scraper_request = ScraperRequest.new
  end

  def create
    reg = ScraperRegistration.find params[:scraper_request][:scraper_registration].to_i
    if reg
      s = ScraperRequest.create(uri: params[:scraper_request][:uri], scraper_registration: reg)
      
      (reg.scraper_class.constantize).new.
        scrape_later((reg.db_model.constantize).
                      create(original_uri: s.uri))
    end
    redirect_to scraper_requests_path
  end

  def index
    @scraper_requests = ScraperRequest.all
  end

  private
  def check_params
    unless params[:scraper_request]
      redirect_to scraper_requests_path
      false
    end
    true
  end
end
