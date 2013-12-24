class ClientCharacteristic < ActiveRecord::Base
  belongs_to :client_category
  has_one :client, dependent: :nullify
  attr_accessible :comment, :client_category_id
  delegate :name, :color, to: :client_category, allow_nil: true
end
