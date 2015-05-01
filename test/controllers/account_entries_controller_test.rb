require 'test_helper'

class AccountEntriesControllerTest < ActionController::TestCase
  test 'tag form retrieves the most common untagged account entry' do
    get :generate_tags
    assert_match 'most common merchant', response.body
  end

  test 'sending a tag correctly creates a record' do
    @params = {original_merchant_name: 'most common merchant', merchant_name: 'most common merchant',
               tag_name: 'new tag from form'}

    original_tag_size = TransactionTag.count

    assert_difference 'AccountEntriesTag.count', 2 do
      post :update_tag, @params
    end

    assert_equal 1 + original_tag_size, TransactionTag.count
  end

  test 'multiple update of account entries works' do
    assert_difference('AccountEntry.count', 2) do
      post :create, {account_entry: {accounts_list: fixture_file_upload('/files/account_entry.csv')}}
    end
  end

  test 'fails correctly on incorrect params' do
    post :update_tag, {}
    assert_redirected_to tag_account_entries_path
  end
end
