class City < ApplicationRecord
  default_scope { order :name }
  scope :main, -> { joins(:departments).where(departments: {id: Department.main_branches}).references(:departments) }

  has_many :departments, inverse_of: :city
  has_many :selectable_departments, -> { Department.selectable }, class_name: 'Department'

  # attr_accessible :name, :color, :time_zone
  validates_presence_of :name
end
