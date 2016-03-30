class Scan < ActiveRecord::Base
  #Scopes for Paperwork and Reports
  scope :scanscount, ->(mystart) { where(monday: mystart, specialservices: true).uniq.pluck(:performance_id).count }
  
  scope :anydate, ->(myday) { where(monday: weekstart(myday)) }

  validates :performance_id, presence: true
  validates :monday, presence: true
end
