module TimesheetDaysHelper

  def timesheet_row(user, date, row_num)
    row_class = 'timesheet_row'
    row_class << ' error' if user.is_fired?
    content_tag(:tr, data: { user: user.id }, class: row_class) do

      content_tag(:td, row_num) +
      content_tag(:td, link_to(user.short_name, user_path(user), target: '_blank'), class: 'fio_col') +
      content_tag(:td, user.job_title, class: 'job_title_col') +
      (date..date.end_of_month).map { |cur_date| timesheet_cell(user, cur_date) }.join.html_safe +
      content_tag(:td, user.work_days_in(date), class: 'work_days_count') +
      content_tag(:td, user.work_hours_in(date), class: 'work_hours_count') +
      content_tag(:td, user.sickness_days_in(date), class: 'sickness_days_count') +
      content_tag(:td, user.latenesses_in(date), class: 'lateness_count')
    end
  end

  def timesheet_cell(user, date)
    cell_class = 'timesheet_day'
    if (timesheet_day = TimesheetDay.find_by_user_id_and_date(user.id, date)).present?
      cell_class << " #{timesheet_day.status}"
      status_abbr = t "timesheet_days.statuses_abbr.#{timesheet_day.status}"
      value = timesheet_day.work_hours
      id = timesheet_day.id
    else
      cell_class << ' empty' unless date.future?
      status_abbr = ''
      value = ''
      id = ''
    end
    content_tag(:td, id: (id.present? ? "timesheet_day_#{id}" : ''), data: { date: date.to_s, id: id }, class: cell_class) do
      content_tag(:span, status_abbr, class: 'status_abbr') +
      tag(:br) +
      content_tag(:span, value, class: 'value')
    end
  end

end