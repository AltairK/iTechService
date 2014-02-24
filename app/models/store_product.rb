class StoreProduct < ActiveRecord::Base

  belongs_to :store
  belongs_to :product
  attr_accessible :warning_quantity, :store_id, :product_id
  validates_presence_of :store, :product
  validates_numericality_of :warning_quantity, only_integer: true, greater_than: 0, allow_nil: true
  validates_uniqueness_of :product_id, scope: :store_id

end
