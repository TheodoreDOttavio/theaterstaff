require 'spec_helper'

describe Performance do
  before do
    @performance = Performance.new(name: "My Show")
  end

  subject { @performance }
      
  it { should respond_to(:name) }
  
  describe "when name is not present" do
    before { @performance.name = " " }
    it { should_not be_valid }
  end
 
  describe "when name is too long" do
    before { @performance.name = "a" * 51 } #generates a 51 long character string
    it { should_not be_valid }
  end
end
