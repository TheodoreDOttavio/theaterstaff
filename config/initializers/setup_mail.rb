ActionMailer::Base.smtp_settings = {
    adress:               "smtp.gmail.com",
    port:                 587,
    domain:               "gmail.com",
    user_name:            "teddottavio@gmail.com",
    password:             ENV['SMTP_PASSWORD'],
    authentication:       :plain,
    enable_starttls_auto: true
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"

ActionMailer::Base.raise_delivery_errors = true