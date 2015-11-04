class AnalysisController < ApplicationController
  def task_page
  end
  
  def execute_task
    if params[:commit]
      if ["Reprocess All Profiles", 'Update Profile Stats', 'Compute Document Universe'].include?(params[:commit])
        flash[:notice] = "Executed command #{params[:commit]}"
        case params[:commit]
        when 'Compute Document Universe'
          DocumentUniverse.reanalyze
        when 'Update Profile Stats'
          ProfileStat.update_all
        when "Reprocess All Profiles"
          @count = 0
          TwitterProfile.all.each do |t|
            @count += 1
           TwitterFetcherJob.perform_later(t, 'bio')
          end
          flash[:notice] += ": Processed #{@count} profiles"
        end
      else
        flash[:error] = "No such command"
      end
    end
    render :task_page
  end
end
