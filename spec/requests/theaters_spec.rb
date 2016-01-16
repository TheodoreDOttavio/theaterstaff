require 'spec_helper'

describe "Theaters" do
    it "Lists available Theaters" do
      user = Factory(:user)
      visit login_path
      click_link "Theater"
    end

end
