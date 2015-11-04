require 'test_helper'
class ProfileStatTest < ActiveSupport::TestCase
  test '::update_all' do
    assert_difference('ProfileStat.count', TwitterProfile.count) do
      ProfileStat.update_all
    end
  end
end
