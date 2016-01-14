class Listdatatable
  include ActiveModel::Model
  include ActiveModel::Validations
  
  extend ActiveModel::Naming

  validates_presence_of :modelname, :description

  attr_accessor :modelname, :description
  def initialize(modelname, description)
    @modelname, @description = modelname, description
  end
  
  
end