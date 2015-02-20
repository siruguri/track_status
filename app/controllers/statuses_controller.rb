class StatusesController < ApplicationController
  # Status controller
  def index
  end

  def create
    permit_keys = [:source, :description, :message]
    if params[:status].nil?
      render nothing: true
    else
      @status = Status.new(params[:status].permit(permit_keys))
      if @status.valid?
        @status.save
        redirect_to @status
      else
        render nothing: true
      end
    end
  end
  
end
