require 'open-uri'

class BindbController < ApplicationController
  # Process bins
  skip_before_filter :verify_authenticity_token

  def index
    @count = BinRecord.count
    @binrec = BinRecord.where('created_at is not NULL').order(created_at: :desc).first
  end

  def dump
    start_index = (params[:start].nil? ? 0 : params[:start].to_i)
    all_recs = BinRecord.offset(start_index).limit(10000)

    payload = all_recs.map do |rec|
      {bin: rec.number, data: {brand: rec.brand, sub_brand: rec.sub_brand, country_code: rec.country_code,
                               country_name: rec.country_name, card_type: rec.card_type, bank: rec.bank,
                               card_category: rec.card_category, lat: rec.lat, long: rec.long}}
    end

    render json: payload.to_json
  end

  def add
    if BinRecord.where(number: params[:bin]).count == 0
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
      if b.valid?
        b.save
        render 'pages/success'
      else
        render 'pages/fail'
      end
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
    
    new_json
  end
      
end
