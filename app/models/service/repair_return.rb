module Service
  class RepairReturn < ActiveRecord::Base
    self.table_name = 'service_repair_returns'

    belongs_to :service_job
    belongs_to :performer, class_name: 'User'
    delegate :repair_parts, :sale, to: :service_job, allow_nil: true

    def self.query(page: nil, date: nil, performer: nil, **)
      repair_returns = RepairReturn.includes(:performer)

      if date.present?
        date = date.t
        repair_returns = repair_returns.where(performed_at: date.beginning_of_day..date.end_of_day)
      end

      if performer.present?
        performer = performer.mb_chars.downcase.to_s
        repair_returns = repair_returns.where('LOWER(name) LIKE :p OR LOWER(surname) LIKE :p', p: performer).references(:users)
      end

      repair_returns.page(page)
    end
  end
end