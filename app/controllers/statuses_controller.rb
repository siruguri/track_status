class StatusesController < ApplicationController
  # Status controller
  skip_before_filter :verify_authenticity_token

  def show
    @status=Status.find params[:id]
  end
  
  def index
    limit = params[:limit] ? params[:limit].to_i : 100
    @statuses = Status.order(created_at: :desc).limit(limit)

    if params[:type]
      @statuses = @statuses.where('description like ?', "%#{params[:type]}%")
    end
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

  def destroy
    # Deletes statuses older than a week (for now)

    day_window = params[:day_window] || 7
    Status.where('created_at < ?', Time.now - day_window.to_i.days).map &:delete

    @statuses = Status.order(created_at: :desc).limit(100)
    render :index
  end
end
