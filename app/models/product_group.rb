class ProductGroup < ActiveRecord::Base
  include Tree

  # default_scope ->{ ordered }
  scope :ordered, ->{ order :position }
  scope :name_asc, ->{order('name asc')}
  scope :services, ->{joins(:product_category).where(product_categories: {kind: 'service'})}
  scope :devices, -> { joins(:product_category).where(product_categories: {kind: 'equipment'}) }
  scope :goods, ->{joins(:product_category).where(product_categories: {kind: %w[equipment accessory]})}
  scope :except_spare_parts, ->{joins(:product_category).where(product_categories: {kind: %w[equipment accessory protector service]})}
  scope :except_spare_parts_and_services, ->{joins(:product_category).where(product_categories: {kind: %w[equipment accessory protector]})}
  scope :except_services, ->{joins(:product_category).where(product_categories: {kind: %w[equipment accessory protector spare_part]})}
  scope :spare_parts, ->{joins(:product_category).where(product_categories: {kind: 'spare_part'})}
  scope :for_purchase, ->{joins(:product_category).where(product_categories: {kind: %w[equipment accessory protector spare_part]})}

  belongs_to :product_category, required: true
  has_many :products, dependent: :nullify, inverse_of: :product_group
  has_many :product_relations, as: :parent, dependent: :destroy
  has_many :related_products, through: :product_relations, source: :relatable, source_type: 'Product'
  has_many :related_product_groups, through: :product_relations, source: :relatable, source_type: 'ProductGroup'
  has_and_belongs_to_many :option_values, join_table: 'product_groups_option_values', uniq: true
  has_many :option_types, -> { distinct }, through: :option_values

  delegate :feature_accounting, :feature_types, :warranty_term, :is_service, :is_equipment, :is_accessory, :is_spare_part, :request_price, to: :product_category, allow_nil: true
  delegate :kind, to: :product_category, prefix: :category, allow_nil: true

  validates_presence_of :name
  validates :code, uniqueness: {allow_blank: true, case_sensitive: false}

  after_initialize :set_product_category

  attr_accessible :code, :name, :ancestry, :parent_id, :product_category_id, :option_value_ids, :related_product_ids, :related_product_group_ids

  has_ancestry orphan_strategy: :restrict, cache_depth: true
  acts_as_list scope: [:ancestry]

  def self.search(params)
    product_groups = ProductGroup.all

    if (form = params[:form]).present?
      case form
        when 'repair_service' then product_groups = product_groups.spare_parts
        when 'purchase' then product_groups = product_groups.for_purchase
        when 'sale' then product_groups = product_groups.except_spare_parts_and_services
        when 'movement_act' then product_groups = User.current.technician? ? product_groups.spare_parts : product_groups.except_spare_parts unless User.current.any_admin?
        else product_groups
      end
    end

    if (store_kind = params[:store_kind]).present?
      case store_kind
        when 'spare_parts', 'defect_sp' then product_groups = product_groups.spare_parts
        when 'purchase' then product_groups = product_groups.for_purchase
        else product_groups = product_groups.except_spare_parts_and_services
      end
    end

    if (user_role = params[:user_role]).present?
      case user_role
        when 'software' then product_groups = product_groups.except_spare_parts_and_services
        when 'technician' then product_groups = product_groups.spare_parts
      end
    end

    product_groups
  end

  def available_options
    option_values.ordered.group_by { |ov| ov.option_type.name }
  end

  private

  def set_product_category
    self.parent_id = nil if parent_id.blank?
    unless is_root?
      self.product_category_id ||= parent.product_category_id
    end
  end

end
