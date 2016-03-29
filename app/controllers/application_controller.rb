class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # This module is available to views and controllers, crossing the MVC architecture
  #  By default these helpers are available in views, but must add it to make it available in controllers
  include ApplicationHelper
  include SessionsHelper

  helper_method :availabilitywindow?

  def weekstart
    astart = DateTime.now.utc.beginning_of_day
    loop do
      break if astart.wday == 1
      astart = astart - 1.day
    end
    return astart
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