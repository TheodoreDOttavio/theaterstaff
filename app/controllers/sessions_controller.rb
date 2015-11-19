class SessionsController < ApplicationController
  def new
  end

  def create
    #form_for tag creates a params hash with a single has that contains email andpass
    user = User.find_by(email: params[:session][:email].downcase)
      if user && user.authenticate(params[:session][:password])
        # Sign the user in and redirect
        sign_in user

        #redirect_to user is traditional,
        #  but we'll go right to their schedule or reports for admin
        redirect_back_or about_path
        # if current_user.admin then
          # redirect_back_or papers_path
        # else
          # redirect_back_or events_path
        # end
      else
        flash.now[:error] = 'Invalid email/password combination'
        render 'new'
      end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
