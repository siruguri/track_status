class StatusRecordsController < ApplicationController
  def create
    str = []
    params.each_pair do |k, v|
      str << "#{k}=#{v}"
    end

    Status.create source: 'record', description: str.join('&'), message: 'hello'
    head :ok
  end
end
