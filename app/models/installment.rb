class Installment < ActiveRecord::Base

  belongs_to :installment_plan, inverse_of: :installments
  attr_accessible :paid_at, :value, :installment_plan, :installment_plan_id

  validates_presence_of :installment_plan, :value

  scope :paid_at, lambda { |period| where(paid_at: period) }

  after_initialize do |rec|
    rec.paid_at ||= Date.current
  end

  after_save do |rec|
    installment_plan.update_attributes is_closed: true if installment_plan.paid_sum >= installment_plan.cost
  end

  def object
    installment_plan.object
  end

end
