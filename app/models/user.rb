class User < ActiveRecord::Base

  ROLES = %w[admin software media technician marketing programmer supervisor manager superadmin driver synchronizer]
  ROLES_FOR_ADMIN = %w[admin software media technician marketing supervisor manager driver]
  HELPABLE = %w[software media technician]
  ABILITIES = %w[manage_wiki manage_salary print_receipt manage_timesheet]

  scope :id_asc, order('id asc')
  scope :ordered, order('position asc')
  scope :any_admin, where(role: %w[admin superadmin])
  scope :superadmins, where(role: 'superadmin')
  scope :software, where(role: 'software')
  scope :media, where(role: 'media')
  scope :technician, where(role: 'technician')
  scope :not_technician, where('role <> ?', 'technician')
  scope :marketing, where(role: 'marketing')
  scope :programmer, where(role: 'programmer')
  scope :supervisor, where(role: 'supervisor')
  scope :manager, where(role: 'manager')
  scope :working_at, lambda { |day| joins(:schedule_days).where('schedule_days.day = ? AND LENGTH(schedule_days.hours) > 0', day) }
  scope :with_active_birthdays, joins(:announcements).where(announcements: {kind: 'birthday', active: true})
  scope :with_inactive_birthdays, joins(:announcements).where(announcements: {kind: 'birthday', active: false})
  scope :schedulable, where(schedule: true)
  scope :staff, where('role <> ?', 'synchronizer')
  scope :fired, where(is_fired: true)
  scope :active, where(is_fired: [false, nil])
  scope :for_changing, where(username: %w[vova admin test test_soft test_media test_tech test_market test_manager])
  scope :exclude, lambda { |user| where('id <> ?', user.is_a?(User) ? user.id : user) }
  #scope :upcoming_salary, where('hiring_date IN ?', [Date.current..Date.current.advance(days: 2)])

  attr_accessor :login
  attr_accessor :auth_token
  cattr_accessor :current

  belongs_to :location
  belongs_to :department
  has_many :history_records, as: :object, dependent: :nullify
  has_many :schedule_days, dependent: :destroy
  has_many :duty_days, dependent: :destroy
  has_many :orders, as: :customer, dependent: :nullify
  has_many :announcements, inverse_of: :user, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :devices, inverse_of: :user
  has_many :karmas, dependent: :destroy, inverse_of: :user
  has_many :karma_groups, through: :karmas, uniq: true
  has_many :bonuses, through: :karma_groups, uniq: true
  has_many :messages, dependent: :destroy
  has_many :infos, inverse_of: :recipient, dependent: :destroy
  has_many :salaries, inverse_of: :user, dependent: :destroy
  has_many :timesheet_days, inverse_of: :user, dependent: :destroy
  has_and_belongs_to_many :addressed_announcements, class_name: 'Announcement', join_table: 'announcements_users', uniq: true
  has_many :installment_plans, inverse_of: :user, dependent: :destroy
  has_many :sales, inverse_of: :user, dependent: :nullify
  has_many :movement_acts, dependent: :nullify
  has_many :stores, through: :department

  mount_uploader :photo, PhotoUploader

  accepts_nested_attributes_for :schedule_days, :duty_days, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :karmas, allow_destroy: true
  accepts_nested_attributes_for :salaries, reject_if: lambda { |attrs| attrs['amount'].blank? or attrs['issued_at'].blank? }
  accepts_nested_attributes_for :installment_plans, reject_if: lambda { |attrs| (attrs['object'].blank? or attrs['cost'].blank? or attrs['issued_at'].blank?) and (attrs['installments_attributes'].blank?) }

  delegate :name, to: :department, prefix: true, allow_nil: true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :registerable, :rememberable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable, :timeoutable, :recoverable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :auth_token, :login, :username, :email, :role, :password, :password_confirmation, :remember_me, :location_id, :surname, :name, :patronymic, :position, :birthday, :hiring_date, :salary_date, :prepayment, :wish, :photo, :remove_photo, :photo_cache, :schedule_days_attributes, :duty_days_attributes, :card_number, :color, :karmas_attributes, :abilities, :schedule, :is_fired, :job_title, :position, :salaries_attributes, :installment_plans_attributes, :installment, :department_id, :session_duration

  validates_presence_of :username, :role, :department
  validates :password, presence: true, confirmation: true, if: :password_required?
  validates :role, inclusion: { in: ROLES }
  validates_numericality_of :session_duration, only_integer: true, greater_than: 0
  before_validation :validate_rights_changing
  before_save :ensure_authentication_token

  acts_as_list

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if auth_token = conditions.delete(:auth_token)
      active.where(conditions).where(["lower(username) = :value OR lower(card_number) = :value", {value: auth_token.mb_chars.downcase.to_s}]).first
    else
      active.where(conditions).first
    end
  end

  after_initialize do |user|
    if user.schedule_days.empty?
      (1..7).each do |d|
        user.schedule_days.build day: d
      end
    end
  end

  def email_required?
    false
  end

  def admin?
    has_role? 'admin'
  end

  def not_admin?
    !admin? and !superadmin?
  end

  def technician?
    has_role? 'technician'
  end

  def software?
    has_role? 'software'
  end

  def media?
    has_role? 'media'
  end

  def marketing?
    has_role? 'marketing'
  end

  def programmer?
    has_role? 'programmer'
  end

  def supervisor?
    has_role? 'supervisor'
  end

  def manager?
    has_role? 'manager'
  end

  def superadmin?
    has_role? 'superadmin'
  end

  def driver?
    self.role == 'driver'
  end

  def synchronizer?
    role == 'synchronizer'
  end
  
  def has_role? role
    if role.is_a? Array
      role.include? self.role
    else
      self.role == role
    end
  end

  def any_admin?
    has_role? %w[admin superadmin]
  end

  def can_view_reports?
    has_role? %w[admin superadmin]
  end

  def self.search(params)
    users = params[:all].present? ? User.scoped : User.active
    unless (q_name = params[:name]).blank?
      users = users.where 'username LIKE :q or name LIKE :q or surname LIKE :q', q: "%#{q_name}%"
    end
    users
  end

  def full_name
    res = [surname, name, patronymic].join ' '
    res = username if res.blank?
    res
  end

  def fio_short
    res = surname
    res += " #{name[0]}." unless name.blank?
    res += " #{patronymic[0]}." unless patronymic.blank?
    res
  end

  def short_name
    res = [name, surname].join ' '
    res = username if res.blank?
    res
  end

  def presentation
    short_name
  end

  def is_duty_day?(date)
    duty_days.exists? day: date
  end

  def is_duty_today?
    duty_days.exists? day: Date.current
  end

  def is_work_day?(day)
    day = day.respond_to?(:wday) ? day.wday : day.to_i
    if (schedule_day = schedule_days.find_by_day(day)).present?
      schedule_day.hours.present?
    else
      false
    end
  end

  def begin_of_work(day)
    self.schedule_days.find_by_day(day.wday).try(:begin_of_work)
  end

  def is_shortened_day?(date)
    if is_work_day? date
      hours = schedule_days.find_by_day(date.wday).hours.split(',').map{|h|h.to_i}.sort
      hours[-1] < 20
    else
      false
    end
  end

  def announced?
    case role
      when 'software' then announcements.active_help.any?
      when 'media' then announcements.active_coffee.any?
      when 'technician' then announcements.active_protector.any?
      else false
    end
  end

  def announced_birthday?
    announcements.active_birthdays.any?
  end

  def helpable?
    User::HELPABLE.include? role
  end

  def color_s
    color.blank? ? '#ffffff' : color
  end

  def upcoming_birthday?
    if birthday.present?
      today = Date.current
      date = birthday.change(year: today.year)
      date = date.next_year if date < today
      date.between? today, 3.days.from_now.end_of_day.to_datetime
    else
      false
    end
  end

  def birthday_announcement
    self.announcements.find_or_create_by_kind(kind: 'birthday', active: false, user: self)
  end

  def timeout_in
    if session_duration.present?
      session_duration.minutes
    else
      30.minutes
    end
  end

  def abilities=(abilities)
    self.abilities_mask = (abilities & ABILITIES).map { |a| 2**ABILITIES.index(a) }.inject(0, :+)
  end

  def abilities
    ABILITIES.reject { |a| ((abilities_mask || 0) & 2**ABILITIES.index(a)).zero? }
  end

  def able_to?(ability)
    abilities.include? ability.to_s
  end

  def location_name(full=false)
    location.blank? ? '' : (full ? location.full_name : location.name)
  end

  def rating
    good_count = karmas.good.count
    bad_count = karmas.bad.count
    (good_count > 0 or bad_count > 0) ? (good_count - bad_count) : 0
  end

  def upcoming_salary_date
    today = Date.current
    date = hiring_date.change month: today.month, year: today.year
    date < today ? date.next_month : date
  end

  def self.oncoming_salary
    today = Date.current
    User.active.all.keep_if do |user|
      if user.hiring_date.present?
        upcoming_salary_date = user.upcoming_salary_date
        upcoming_salary_date.between?(today, 2.days.from_now.end_of_day.to_datetime) and user.salaries.where(created_at: today..upcoming_salary_date, user_id: user.id).empty?
      end
    end.sort_by! do |user|
      user.upcoming_salary_date - today
    end
  end

  def work_days_in(date)
    timesheet_days.in_period(date).work.count
  end

  def work_hours_in(date)
    timesheet_days.in_period(date).work.sum do |day|
      day.actual_work_hours
    end
  end

  def sickness_days_in(date)
    timesheet_days.in_period(date).sickness.count
  end

  def latenesses_in(date)
    timesheet_days.in_period(date).lateness.count
  end

  def installment=(params)
    if params[:installment_plan_id].present? and params[:value].present? and params[:paid_at].present?
      if (installment_plan = self.installment_plans.find(params[:installment_plan_id])).present?
        installment_plan.installments.create value: params[:value], paid_at: params[:paid_at]
      end
    end
  end

  def installments
    Installment.where installment_plan_id: self.installment_plan_ids
  end

  def self.check_birthdays
    User.active.find_each do |user|
      announcement = user.birthday_announcement
      announcement.update_attributes active: user.upcoming_birthday?
      if announcement.active?
        announcement.recipient_ids = User.any_admin.map { |u| u.id }
        announcement.save
      end
    end
  end

  def timesheet_day(date)
    self.timesheet_days.find_by_date(date)
  end

  def retail_store
    stores.retail.first
  end

  def spare_parts_store
    stores.spare_parts.first
  end

  def defect_store
    stores.defect.first
  end

  def defect_sp_store
    stores.defect_sp.first
  end

  def cash_drawer
    department.cash_drawers.first
  end

  def current_cash_shift
    cash_drawer.try(:current_shift)
  end

  private

  def validate_rights_changing
    if (changed_attributes[:role].present? or changed_attributes[:abilities].present?) and !User.current.superadmin?
      errors[:base] << 'Rights changing denied!'
    end
  end

  def ensure_an_admin_remains
    errors[:base] << I18n::t('users.deny_destroing') and return false if User.superadmins.count == 1
  end

  def password_required?
    self.new_record?
  end
  
end
