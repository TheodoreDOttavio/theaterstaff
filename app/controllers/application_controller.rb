class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # This module is available to views and controllers, crossing the MVC architecture
  #  By default these helpers are available in views, but must add it to make it available in controllers
  include ApplicationHelper
  include SessionsHelper


  #helper_method :availabilitywindow?

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

  def languagelist
    languages = {:Infrared=>0, :iCaption=>1, :dScript=>2, :Chinese=>3, :French=>4, :German=>5, :Japanese=>6, :Portugese=>7, :Spanish=>8, :Turkish=>9}
    return languages
  end


  def availabilitywindow?
    #To generate a link to submit user availability
    #  or a link to the schedule based on the day of the week
    #Returns True when the user may post

    checkthis = DateTime.now

    case checkthis.wday
      when 0 #0 is Sunday
        if checkthis.hour > 18
          return true
        end
      when 1
        return true
      when 2
        if checkthis.hour < 20
          return true
        end
      else
        return false
    end
  end

end