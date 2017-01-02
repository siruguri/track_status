class StatusRecordsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def create
    str = []
    params.each_pair do |k, v|
      str << "#{k}=#{v}"
    end

    Status.create source: 'record', description: str.join('&'), message: 'hello'
    head :ok
  end
end
