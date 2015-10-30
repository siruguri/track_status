class AnalysisController < ApplicationController
  def task_page
  end
  
  def execute_task
    if params[:commit] and ['Compute Document Universe'].include?(params[:commit])
      flash[:notice] = "Executed command #{params[:commit]}"
      DocumentUniverse.reanalyze
    else
      flash[:error] = "No such command"
    end
    render :task_page
  end
end
