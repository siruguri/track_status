class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :channel_secrets, dependent: :destroy
  has_many :token_hash_records, class_name: 'OauthTokenHash'

  def token_hash
    m = {}
    if token_hash_records
      t_rec = token_hash_records.order(created_at: :desc).limit(1).first
      m = {token: t_rec.token, secret: t_rec.secret}
    end
    m
  end    
end
