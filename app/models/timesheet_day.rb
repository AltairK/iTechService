class TimesheetDay < ActiveRecord::Base

  STATUSES = %w[presence presence_late presence_leave presence_sickness sickness free fired business_trip training]

  belongs_to :user, inverse_of: :timesheet_days
  attr_accessible :time, :date, :status, :work_mins, :work_hours, :user, :user_id
  #attr_accessor :work_hours

  validates_presence_of :user_id, :date, :status
  validates_inclusion_of :status, in: STATUSES

  scope :in_period, lambda { |date| period = date.is_a?(Range) ? date : date.beginning_of_month..date.end_of_month; where(date: period) }
  scope :work, where('timesheet_days.status LIKE ? OR timesheet_days.status = ?', 'presence%', 'business_trip')
  scope :sickness, where(status: 'sickness')
  scope :lateness, where(status: 'presence_late')

  def actual_work_mins
    if work_mins.present?
      if status == 'presence_late'
        if (schedule_day = user.schedule_days.find_by_day(date.wday)).present? and (end_of_work = schedule_day.end_of_work(date_time)).present?
          (end_of_work - date_time) / 60
        else
          work_mins
        end
      elsif status == 'presence_leave'
        if (schedule_day = user.schedule_days.find_by_day(date.wday)).present? and (begin_of_work = schedule_day.begin_of_work(date_time))
          (date_time - begin_of_work) / 60
        else
          work_mins
        end
      else
        work_mins
      end
    else
      0
    end
  end

  def actual_work_hours
    actual_work_mins.nonzero? ? (actual_work_mins / 60) : 0
  end

  def date_time
    Time.new(date.year, date.month, date.day, time.hour, time.min)
  end

  def work_hours
    work_mins.present? ? (work_mins / 60) : 0
  end

  def work_hours=(value)
    self.work_mins = value.to_i * 60
  end

end
