module Service
  class FreeJob < ActiveRecord::Base
    self.table_name = 'service_free_jobs'

    scope :new_first, -> { order performed_at: :desc }

    belongs_to :performer, class_name: 'User'
    belongs_to :client
    belongs_to :task, class_name: 'FreeTask'

    delegate :presentation, :short_name, to: :client, prefix: true
    delegate :short_name, to: :performer, prefix: true
  end
end