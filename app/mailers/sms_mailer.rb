require 'people_helper' #to look up email from yaml file
require 'events_helper'

class SmsMailer < ActionMailer::Base
  include PeopleHelper #to look up email from yaml file
  include EventsHelper

  default from: "teddottavio@yahoo.com"
  #default url_options: "example.com"

  def schedule_for_txt_msg(user)
    mystart = weekstart
    myend = mystart + 7.days

    @events = Event.where("curtain > ? AND curtain < ? AND user_id == ?",
     mystart, myend, user.id).order(:curtain)

    @events.map do |e|
      e.curtain = e.curtain - 1.hour
    end

    #lookup email from yaml file
    getemail = carriers[user.phonetype]['value'].to_s

    serviceemail =  user.phone.gsub(/[^0-9]/, "") + getemail

    mail(:to => serviceemail,
      :subject => "Schedule for " + user.name + " for the week of " + weekstart.strftime('%a, %b %d'))
  end


  def schedule_for_email(user)
    #need to generate schedule and use mailer views to render schedule
    mail(:to => user.email, :subject => 'Schedule')
  end


  def theaterschedule_for_txt_msg(person)
    mystart = weekstart
    myend = mystart + 7.days

    performance = Performance.find_by_theater_id(person.theater_id)

    @events = Event.where("curtain > ? AND curtain < ? AND performance_id == ?",
     mystart, myend, performance.id).order(:curtain)

    #lookup email from yaml file
    getemail = carriers[person.phonetype]['value'].to_s

    serviceemail =  person.phone.gsub(/[^0-9]/, "") + getemail

    mail(:to => serviceemail,
      :subject => "Staff for the week of " + weekstart.strftime('%a, %b %d'))
  end

end