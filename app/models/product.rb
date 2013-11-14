class Product < ActiveRecord::Base

  BARCODE_PREFIX = '243'

  belongs_to :product_group, inverse_of: :products
  has_many :items, inverse_of: :product, dependent: :destroy
  has_many :prices, class_name: 'ProductPrice', inverse_of: :product, dependent: :destroy
  has_many :store_items, through: :items, dependent: :destroy
  has_many :revaluations, inverse_of: :product, dependent: :destroy
  has_one :task, inverse_of: :product, dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true
  accepts_nested_attributes_for :task, allow_destroy: false
  attr_accessible :code, :name, :product_group_id, :warranty_term, :items_attributes, :task_attributes
  validates_presence_of :name, :code, :product_group
  validates_uniqueness_of :code
  delegate :feature_accounting, :feature_types, :is_service?, :request_price, :product_category, to: :product_group, allow_nil: true

  scope :available, includes(:store_items).where('store_items.quantity > ?', 0)
  scope :in_store, lambda { |store| includes(:store_items).where(store_items: { store_id: store.is_a?(Store) ? store.id : store }) }
  scope :goods, joins(:product_group).where(product_groups: {is_service: false})
  scope :services, joins(:product_group).where(product_groups: {is_service: true})

  after_save { self.is_service? ? self.create_task : self.task.try(:destroy) }

  after_initialize { self.warranty_term ||= default_warranty_term }

  def self.search(params)
    products = Product.scoped

    unless (product_q = params[:product_q]).blank?
      products = products.where 'LOWER(name) LIKE :q OR code LIKE :q', q: "%#{product_q.mb_chars.downcase.to_s}%"
    end

    unless (q = params[:q]).blank?
      products = products.includes(items: :features).where('features.value = :q OR products.name LIKE :q1', q: q, q1: "%#{q}%")
    end

    products
  end

  def purchase_price
    prices.purchase.first.try(:value)
  end

  def retail_price
    prices.retail.first.try(:value)
  end

  def actual_prices
    {
      purchase: purchase_price,
      retail: retail_price
    }
  end

  def available_quantity(store=nil)
    if store.present?
      store_items.in_store(store).sum(:quantity)
    else
      store_items.sum(:quantity)
    end
  end

  def available_quantity_by_stores
    Store.all.map {|store| {code: store.code, name: store.name, quantity: available_quantity(store)}}
  end

  def item
    (!feature_accounting and items.any?) ? items.first_or_create : nil
  end

  def default_warranty_term
    product_group.warranty_term
  end

  def discount_for(client)
    client.present? ? Discount::available_for(client, self) : 0
  end

end
