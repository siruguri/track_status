require 'csv'
class AccountEntriesController < ApplicationController
  before_action :check_params, only: [:update_tag]
  
  def new
  end
  
  def create
    file_content = params[:account_entry][:accounts_list]

    k=file_content.read
    CSV.parse(k) do |fields|
      unless /^\(/.match(fields[1])
        a = AccountEntry.new(entry_date: Date.strptime(fields[0], '%m/%d/%Y'),
                             entry_amount: fields[1].gsub(/^\$/, '').to_f,
                             merchant_name: fields[2])
        a.save
      end
    end

    render :new
  end

  def generate_tags
    # Pick an untagged account entry and send it back
    @data = AccountEntry.untagged.group(:merchant_name).order('count_id desc').count.first
  end

  def update_tag
    candidates = AccountEntry.untagged.where(merchant_name: params[:original_merchant_name])
    @generated_tags = candidates.count

    unless candidates.empty?
      candidates.each do |entry|
        if params[:merchant_name] != params[:original_merchant_name]
          entry.merchant_name = params[:merchant_name]
          entry.save
        end

        entry.transaction_tags << TransactionTag.find_or_create_by(tag_name: params[:tag_name])
      end
    end
    
    @data = AccountEntry.untagged.group(:merchant_name).order('count_id desc').count.first

    render :generate_tags
  end

  private

  def check_params
    if params[:action] == 'update_tag'
      unless params[:original_merchant_name] and params[:merchant_name] and params[:tag_name]
        redirect_to tag_account_entries_path
        return false
      end
    end
    true
  end
end
