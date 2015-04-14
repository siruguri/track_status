class DummyController < ApplicationController
  def test_env
    @mesg = ENV['test_var']
  end
end
