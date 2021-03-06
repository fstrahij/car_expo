class User < ApplicationRecord
	attr_accessor :remember_token, :activation_token
	before_create :create_activation_digest

	validates :first_name, presence: true, length: { maximum: 30 }
	validates :last_name, presence: true, length: { maximum: 50 }
	validates :user_name, presence: true, uniqueness: true, length: { minimum: 8, maximum: 30 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, uniqueness: true, length: { maximum: 50 }, 
												format: { with: VALID_EMAIL_REGEX }
	has_secure_password		
	validates :password, presence: true, length: { minimum: 6 }	

	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string , cost:  cost)
	end

	def self.new_token
		SecureRandom.urlsafe_base64
	end							

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def activate
	 	update_attribute(:active, true)
		update_attribute(:activated_at, Time.zone.now)
	end 

	def send_activation_email
	 	UserMailer.account_activation(self).deliver_now
	end

	private
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end 
end
