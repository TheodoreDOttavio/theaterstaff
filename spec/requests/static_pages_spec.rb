require 'rails_helper'

describe "Static pages" do

  describe "Home page" do
    it "should have the content 'Theater Staff'" do
      visit '/static_pages/home'
      expect(page).to have_content('Theater Staff')
    end
  end


  describe "Help page" do
    before { visit help_path }
 
     it { should have_content('Help') }
     it { should have_title(full_title('Help')) }
  end

end