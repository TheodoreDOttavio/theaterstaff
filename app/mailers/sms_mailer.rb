class SmsMailer < ActionMailer::Base
  default from: "teddottavio@yahoo.com"
  #default url_options: "example.com"


  def send_auto_password(useremail, possible_password)
    @possible_password = possible_password
    mail(:to => useremail, :subject => 'Theater Staffing App Temp Password')
  end


  def schedule_for_txt_msg(user)
    mystart = weekstart

    # @events = Event.where("curtain > ? AND curtain < ? AND user_id == ?",
     # mystart, myend, user.id).order(:curtain)

    # @events.map do |e|
      # e.curtain = e.curtain - 1.hour
    # end

    #lookup email from yaml file and create full email adress
    getemail = carriers[user.phonetype]['value'].to_s
    serviceemail =  user.phone.gsub(/[^0-9]/, "") + getemail

    mail(:to => serviceemail,
      :subject => "SA -" + user.name + ": Schedule for the week of " + weekstart.strftime('%a, %b %d'))
  end


  def schedule_for_email(user)
    #need to generate schedule and use mailer views to render schedule
    mail(:to => user.email, :subject => 'Schedule')
  end
end