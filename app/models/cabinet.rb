class Cabinet < ActiveRecord::Base
  belongs_to :product
  belongs_to :performance
end