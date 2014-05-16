class SupplyRequest < ActiveRecord::Base

  STATUSES = %w[new done]

  scope :created_desc, order('created_at desc')
  scope :actual, where(status: 'new')

  belongs_to :department
  belongs_to :user
  delegate :name, :short_name, :presentation, to: :user, prefix: true

  attr_accessible :user_id, :status, :object, :description
  validates_presence_of :user, :status, :object

  after_initialize do
    user_id ||= User.current.try(:id)
    status ||= 'new'
  end

  def self.search(params)
    supply_requests = SupplyRequest.scoped

    if (number_q = params[:number]).present?
      supply_requests = supply_requests.where id: number_q
    end

    if (object_q = params[:object]).present?
      supply_requests = supply_requests.where 'LOWER(object) LIKE :q', q: "%#{object_q.mb_chars.downcase.to_s}%"
    end

    if (user_q = params[:user]).present?
      supply_requests = supply_requests.joins(:user).where 'LOWER(users.name) LIKE :q OR LOWER(users.surname) LIKE :q OR LOWER(users.username) LIKE :q', q: "%#{user_q.mb_chars.downcase.to_s}%"
    end

    supply_requests
  end

  def is_new?
    status == 'new'
  end

  def is_done?
    status == 'done'
  end

end
