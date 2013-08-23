class Category < ActiveRecord::Base
  has_and_belongs_to_many :feature_types
  attr_accessible :name, :feature_type_ids
  validates_presence_of :name
end
