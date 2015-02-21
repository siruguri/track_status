class StatusesController < ApplicationController
  # Status controller
  skip_before_filter :verify_authenticity_token

  def show
    @status=Status.find params[:id]
  end
  
  def index
  end

  def create
    permit_keys = [:source, :description, :message]
    if params[:status].nil?
      render nothing: true, status: 400
    else
      @status = Status.new(params[:status].permit(permit_keys))
      if @status.valid?
        @status.save
        redirect_to @status
      else
        render nothing: true, status: 500
      end
    end
  end
  
end
