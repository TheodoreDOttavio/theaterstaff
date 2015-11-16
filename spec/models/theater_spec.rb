require 'spec_helper'

describe Theater do
  before do
    @theater = Theater.new(name: "My Theater", address: "100 East 45th")
  end

  subject { @theater }
      
  it { should respond_to(:name) }
  it { should respond_to(:address) }
  
  describe "when name is not present" do
    before { @theater.name = " " }
    it { should_not be_valid }
  end
 
 describe "when address is not present" do
    before { @theater.address = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @theater.name = "a" * 51 } #generates a 51 long character string
    it { should_not be_valid }
  end
  
  describe "when lock combination is too long" do
    before { @theater.commentslock = "a" * 5 } #generates a 51 long character string
    it { should_not be_valid }
  end
end
