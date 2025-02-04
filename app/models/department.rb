class Department < ApplicationRecord
  include Searchable
  search_by :name, initials: { case_sensitive: true }

  include Members
  build_member_methods(relationship: :users, name: :member)

  has_many :department_modules, dependent: :destroy
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users
  has_many :documents, dependent: :destroy

  validates :name, presence: true
  validates :initials, presence: true, uniqueness: true
  validates :local, presence: true
  validates_email_format_of :email, message: I18n.t('errors.messages.invalid')
  validates :email, uniqueness: true
  validates :phone, format: { with: /\A\(\d{2}\)\s\d{4,5}-\d{4}\z/ }

  def modules
    department_modules
  end

  def user_is_collaborator?(user)
    department_users.find_by(user_id: user.id).role.eql?('collaborator')
  end
end
