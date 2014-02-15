class DeviceTask < ActiveRecord::Base

  scope :ordered, joins(:task).order('done asc, tasks.priority desc')
  scope :done, where(done: true)
  scope :pending, where(done: false)
  scope :tasks_for, lambda { |user| joins(:device, :task).where(devices: {location_id: user.location_id}, tasks: {role: user.role}) }

  belongs_to :device
  belongs_to :task
  has_many :history_records, as: :object
  has_many :repair_tasks
  has_many :repair_parts, through: :repair_tasks
  accepts_nested_attributes_for :device, reject_if: proc { |attr| attr['tech_notice'].blank? }
  accepts_nested_attributes_for :repair_tasks

  delegate :name, :role, :is_important?, :is_actual_for?, to: :task, allow_nil: true
  delegate :client_presentation, to: :device, allow_nil: true
  delegate :is_repair?, to: :task, allow_nil: true
  attr_accessible :done, :comment, :user_comment, :cost, :task, :device, :device_id, :task_id, :task, :device_attributes, :repair_tasks_attributes
  validates :task, :cost, presence: true
  #validates :cost, numericality: true
  validates_numericality_of :cost#, greater_than_or_equal_to: :repair_cost
  validates_associated :repair_tasks
  validate :valid_repair if :is_repair?
  after_commit :update_device_done_attribute
  after_save :deduct_spare_parts if :is_repair?
  after_initialize { self.done ||= false }

  before_save do |dt|
    old_done = changed_attributes['done']
    if dt.done and (!old_done or old_done.nil?)
      dt.done_at = DateTime.current
    elsif !dt.done and old_done
      dt.done_at = nil
    end
  end

  def as_json(options={})
    {
      id: id,
      name: name,
      done: done,
      cost: cost,
      comment: comment,
      user_comment: user_comment
    }
  end

  def task_name
    task.try :name
  end

  def task_cost
    task.try(:cost) || 0
  end
  
  def task_duration
    task.try :duration
  end

  def device_presentation
    device.present? ? device.presentation : ''
  end

  def performer
    if (completions = history_records.task_completions).any?
      completions.last.try :user
    else
      nil
    end
  end

  def performer_name
    performer.present? ? performer.short_name : ''
  end

  #def validate_device_tasks
  #  roles = []
  #  device_tasks.each do |dt|
  #    if roles.include? dt.role and dt.role == 'software'
  #      self.errors.add(:device_tasks, I18n.t('devices.device_tasks_error'))
  #    else
  #      roles << dt.role
  #    end
  #  end
  #end

  def repair_cost
    repair_tasks.sum(:price)
  end

  private

  def update_device_done_attribute
    done_time = self.device.done? ? self.device.device_tasks.maximum(:done_at).getlocal : nil
    self.device.update_attribute :done_at, done_time
  end

  def deduct_spare_parts
    repair_parts.each { |repair_part| repair_part.deduct_spare_parts }
  end

  def valid_repair
    is_valid = true
    if done_changed? and done_was
      errors.add :done, :already_done
      is_valid = false
    else
      repair_parts.each do |repair_part|
        if repair_part.store_item(repair_part.store).quantity < (repair_part.quantity + repair_part.defect_qty)
          errors[:base] << I18n.t('device_tasks.errors.insufficient_spare_parts', name: repair_part.name)
          is_valid = false
        end
      end
      if repair_parts.sum(:defect_qty) > 0 and (Store.defect.empty?)
        errors.add :base, :no_defect_store
        is_valid = false
      end
    end
    is_valid
  end

end