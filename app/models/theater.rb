class Theater < ActiveRecord::Base

  has_one :performance
  accepts_nested_attributes_for :performance

  validates :name, presence: true, length: { maximum: 50 }
  validates :address, presence: true
  validates :city, presence: true
  validates :commentslock, length: { maximum: 4 }
  
  delegate :name, :closeing, :to => :performance, :prefix => true
  
  def companylist
    companies = []
    companies.push(["Independent","Independent"])
    companies.push(["Disney","Disney"])
    companies.push(["Nederlander","Nederlander"])
    companies.push(["Jujamcyn","Jujamcyn"])
    companies.push(["Schubert","Schubert"])
    companies.push(["Roundabout","Roundabout"])
    return companies
  end
end
