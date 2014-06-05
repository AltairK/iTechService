class ImportedSale < ActiveRecord::Base
  scope :sold_at, lambda { |period| where(sold_at: period) }
  belongs_to :device_type
  attr_accessible :imei, :quantity, :serial_number, :sold_at, :device_type_id

  def self.search(params)
    imported_sales = ImportedSale.scoped

    if (search = params[:search]).present?
      imported_sales = imported_sales.where 'LOWER(imported_sales.serial_number) = :s OR LOWER(imported_sales.imei) = :s', s: "#{search.mb_chars.downcase.to_s}"
    end

    imported_sales
  end

  def device_type_name
    device_type.present? ? device_type.full_name : '-'
  end

end