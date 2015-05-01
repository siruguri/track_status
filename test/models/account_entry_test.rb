require 'test_helper'

class AccountEntryTest < ActiveSupport::TestCase
  def setup
    @all_params = [:entry_amount, :entry_date, :merchant_name]
    @attrs = {entry_amount: '123.11', entry_date: Time.now, merchant_name: 'hello'}
  end
  
  test 'validations work' do
    a = AccountEntry.new(entry_amount: 'a', entry_date: Time.now, merchant_name: 'hello')
    assert_not a.valid?

    @all_params.each do |key|
      assert_not AccountEntry.new(@attrs.reject { |k, v| k == key}).valid?
    end
  end

  test 'untagged scope works' do
    assert_equal 3, AccountEntry.untagged.count
  end
end
