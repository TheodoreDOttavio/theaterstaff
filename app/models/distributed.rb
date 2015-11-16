class Distributed < ActiveRecord::Base
  belongs_to :product
  belongs_to :performance

  #Scopes for xls and pdf reports

  scope :datespan, ->(mystart, myend) { where(curtain: [mystart..myend]) }

  scope :infrared, -> { where(product_id: [1,3,6,7]) }
  scope :translation, -> { where(product_id: [4,5], language: [2..20]) }
  scope :icapdesc, -> { where(product_id: [4,5], language: [0..1]) }

  scope :onday, ->(myday) { where(curtain: [(myday)..(myday + 1)]) }

  scope :delivered, -> {where('quantity > 0')}

  #Scopes for Paperwork and Reports
  scope :allperformances, ->(mystart, myend) {
    where(curtain: [mystart..myend]).distinct.pluck(:performance_id) }
  scope :oneperformance, ->(mystart, myend, theater) {
    where(curtain: [mystart..myend], performance_id: theater.performance.id).distinct.pluck(:performance_id) }
  scope :infrared_for_oneperformance, ->(mystart, myend, performanceid) {
    where(curtain: [mystart..myend], performance_id: performanceid).infrared.order(:curtain, :eve) }
end
