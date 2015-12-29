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
  scope :language_for_oneperformance, ->(mystart, myend, languageid, performanceid) {
    where(curtain: [mystart..myend], performance_id: performanceid, language: languageid).order(:curtain, :eve) }

  #Scopes for data entry
  scope :infraredwkcount, ->(mystart) { where(product_id: [1,3,6,7]).datespan(mystart, (mystart+7)).uniq.pluck(:performance_id).count }
  scope :specialservicewkcount, ->(mystart) { where(product_id: [4,5], language: [2..20]).datespan(mystart, (mystart+7)).uniq.pluck(:performance_id).count }
  scope :shiftwkcount, ->(mystart) { where(product_id: [1,6]).datespan(mystart, (mystart+7)).count }
  scope :representativewkcount, ->(mystart) { where(product_id: [1,6], representative: [2..1000]).datespan(mystart, (mystart+7)).count }
  scope :representativetbdwkcount, ->(mystart) { where(product_id: [1,6], representative: [nil,0,1]).datespan(mystart, (mystart+7)).count }

  #Show a representative's work with links to scanned logs
  scope :schedule, ->(repid) { where(product_id: [1,3,6,7], representative: repid).order(curtain: :desc) }
  
  scope :allmonths, -> {
    allmonths = []
    astart = DateTime.now.utc.beginning_of_day
    for i in 1..700 do
      mystart = astart - i
      if mystart.strftime('%d') == '01' then
        if self.datespan(mystart, (mystart+30)).infrared.exists? then
          allmonths.push([mystart.strftime('%Y: %b'),mystart])
        end
      end
    end
    return allmonths
  }

  scope :allweeks, ->(wkstart){
    allweeks = []
    for i in 1..100 do
      mystart = wkstart - (i * 7)
      myend = mystart + 6
      #check to see if there's any data at all on that week
      if self.datespan(mystart, myend).infrared.exists? then
        allweeks.push([mystart.strftime('%Y: %b %d')+" to "+ myend.strftime('%b %d'),mystart])
      end
    end
    return allweeks
  }

  #Complete weeks goes back 3 years - used to place images (text vs. timestamp)
  scope :completeweeks, ->(wkstart){
    completeweeks = []
    for i in 1..156 do
      mystart = wkstart - (i * 7)
      myend = mystart + 6
      completeweeks.push([mystart.strftime('%Y: %b %d')+" to "+ myend.strftime('%b %d'), mystart.strftime('%Y-%m-%d')])
    end
    return completeweeks
  }
end
