class RedirectMapsController < ApplicationController
  def show
    src = params[:id]
    if r=RedirectMap.find_by_src(src)
      redirect_to r.dest
    else
      render nothing: true
    end
  end
end

