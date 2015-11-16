class Performance < ActiveRecord::Base
  belongs_to :theater

  has_many :products, :through => :cabinets
  has_many :cabinets, dependent: :destroy

  accepts_nested_attributes_for :cabinets,
           :reject_if => :all_blank,
           :allow_destroy => true


  has_many :users, :through => :events
  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events,
           :reject_if => :all_blank,
           :allow_destroy => true

    #validates_associated :events
    validates :name, presence: true, length: { maximum: 50 }

    scope :showing, ->(mystart, myend) { where("opening <= ? and closeing >= ?", mystart, myend) }
    scope :nowshowing, -> { where("closeing >= ?", DateTime.now) }
    scope :dark, -> { where("closeing < ?", DateTime.now) }
end