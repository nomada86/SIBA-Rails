class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  
  before_save :fullname
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook]
  
  #validates_integrity_of  :avatar
  #validates_processing_of :avatar

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.username = auth.info.nickname
      user.password = Devise.friendly_token[0,20]
      user.full_name = auth.info.name
      user.last_name = auth.info.last_name
      user.first_name = auth.info.first_name
      user.avatar = auth.info.image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  private
  def fullname
    if self.full_name.nil?
      self.full_name = [first_name, last_name].join(' ')
    end
  end
end
