require 'open-uri'

class BindbController < ApplicationController
  # Process bins
  skip_before_filter :verify_authenticity_token

  def add
    url = 'http://www.binlist.net/json/' + params[:bin]
    begin
      resp = open(url).each_line.map { |l| l }.join('')
    rescue OpenURI::HTTPError => e
      render 'pages/fail', status: 404
      return
    end
    
    json = JSON.parse resp
    json['number']=json['bin']

    clean_json = clean_binlist_resp(json)

    b=BinRecord.new(clean_json)
    if b.valid? and BinRecord.where(number: clean_json[:number]).count == 0
      b.save
      render 'pages/success'
    else
      render 'pages/fail'
    end
  end

  private
  def clean_binlist_resp(json)
    new_json = json.keys.inject({}) do |hash, k|
      hash[k.to_sym]=json[k]
      hash
    end

    new_json[:lat] = new_json[:latitude].to_f
    new_json[:long] = new_json[:longitude].to_f

    [:bin, :latitude, :longitude, :query_time].each { |k| new_json.delete k}
    
    new_json#.permit(:number, :bank, :card_type, :card_category, :brand, :sub_brand, :country_code, :country_name, :lat,                    :long)
  end
      
end
