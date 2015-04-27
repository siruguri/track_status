class DummyController < ApplicationController
  def env
    @message = ENV.inspect

    render :test_env
  end
end
