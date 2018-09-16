class ImportedSale < ActiveRecord::Base
  scope :sold_at, ->(period) { where(sold_at: period) }
  belongs_to :device_type
  attr_accessible :imei, :quantity, :serial_number, :sold_at, :device_type_id

  def self.search(params)
    if (search = params[:search]).present?
      ImportedSale.where 'LOWER(imported_sales.serial_number) = :s OR LOWER(imported_sales.imei) = :s', s: "#{search.mb_chars.downcase.to_s}"
    else
      ImportedSale.none
    end
  end

  def device_type_name
    device_type.present? ? device_type.full_name : '-'
  end

  alias_attribute :date, :sold_at
end
