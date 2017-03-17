# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account                :jsonb
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :yards

  before_validation :init_account
  validate :validate_account_status

  def account_status=(status)
    self.account['status'] = status
  end

  def account_status
    self.account['status']
  end

  private

  def init_account
    self.account['status'] ||= 'trial'
    self.account['payments'] ||= []
  end

  def validate_account_status
    errors.add(:account_status, 'is not valid') unless %w(trial full_access).include?(self.account['status'])
  end
end
