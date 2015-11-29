class Performance < ActiveRecord::Base    
  belongs_to :theater

  has_many :products, :through => :cabinets
  has_many :cabinets, dependent: :destroy

  accepts_nested_attributes_for :cabinets,
           :reject_if => :all_blank,
           :allow_destroy => true

  validates :name, presence: true, length: { maximum: 50 }

  delegate :name, :company, :address, :city, :to => :theater, :prefix => true
  
  scope :showinglist, ->(mystart) { where("closeing >= ? and opening <= ?", mystart, mystart).select(:id, :name).order(:name) }
  scope :showingcount, ->(mystart, myend) { where("opening <= ? and closeing >= ?", mystart, myend).uniq.pluck(:id).count }
  scope :nowshowing, -> { where("closeing >= ?", DateTime.now) }
  scope :dark, -> { where("closeing < ?", DateTime.now) }
end