class UsersController < ApplicationController

before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
before_action :correct_user,   only: [:edit, :update]
before_action :admin_user,     only: :destroy

  def index
    @users = User.where('id != 1').paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    #@scheduleds = Distributed.infrared.where(representative: params[:id]).order(:curtain)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Theater Staffing App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    # Taken care of by sessions helper correct_user
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def txtalert
    @user = User.find(params[:id])
    SmsMailer.schedule_for_txt_msg(@user).deliver
    flash[:success] = "A txt Message was sent to " + @user.name
    #+ " -- " + @user.phone.gsub(/[^0-9]/, "") + carriers[@user.phonetype]['value'].to_s

    #redirect_to @user
    redirect_to users_url
  end

  def emailalert
    @user = User.find(params[:id])
    SmsMailer.schedule_for_email(@user).deliver
    flash[:success] = "A email was sent to " + @user.name + "  [" + @user.email + "]"
    #redirect_to @user
    redirect_to users_url
  end


  private

    def user_params
      params.require(:user).permit(:name,
      :email,
      :password,
      :password_confirmation,
      :txtupdate,
      :alert,
      :alerttime,
      events_attributes: [ :id,
        :performance_id,
        :user_id,
        :curtain,
        :post,
        :opening,
        :closing ],
      available_attributes: [ :id,
        :day,
        :mat,
        :eve ],
      performances_attributes: [ :id,
        :name])
    end

    # Before filters

    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?

      # this is a more verbose version of the above line:
      #unless signed_in?
      #  flash[:notice] = "Please sign in."
      #  redirect_to signin_url
      #end
    end

    def correct_user
      #this allows only a user or admin to get at the edit screen
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end

#current list of representatives:
#wambui@wambui.com; Adam Shonkwiler <adamshonkwiler@gmail.com>; Anna Lively <anna@annalively.com>; Anthony Raus <anthonyraus@gmail.com>; Anya Aliferis <anya.aliferis@gmail.com>; Ashley Griffin <faeriebleue@aol.com>; Beth Anne Sacks <bethannesacks@gmail.com>; BETH NAJI <bnajishow@aol.com>; Bobby Matteau <bobby.matteau@gmail.com>; C K Browne <ckendallbrowne@gmail.com>; Camron Gran <camrongran@hotmail.com>; Carla Cherry <carlaremy@gmail.com>; Cathleen Wright <cathleen@cathleenwright.com>; Cindy <cinshee@aol.com>; Cynthia Ladopoulos <nycindytours@gmail.com>; D. Levy <levdm5@gmail.com>; Dakota DeFelice <dakotadefelice@gmail.com>; Dani Marcus <danimarcus2002@yahoo.com>; David Kellner <david_kellner7@hotmail.com>; Denise Bourcier <dabourcier@gmail.com>; Devin Vogel <devin.i.vogel@gmail.com>; Edward Batchelor <ebatchelor72@gmail.com>; Eileen F. Dougherty <efdoughert@aol.com>; Emily Adamo <emilyeadamo@gmail.com>; Emily Rhein <emily.rhein@gmail.com>; Erika Jenko <onceuponareality@gmail.com>; Gigi Soriano <gigisoriano811@gmail.com>; Gregory Bertolini <gregbertolini@yahoo.com>; Jacqueline Keeley <jackiekeeley@gmail.com>; Jane Moore <jmoore1@gm.slc.edu>; Jane Van gelder <janevangelder@yahoo.com>; Jelissa Mercado <jelissam21@gmail.com>; Jennifer Cooper <jenlizcooper@gmail.com>; Jennifer Menter <jennifer.menter@gmail.com>; Julien BRAUN <julienbraun@icloud.com>; Kelsey Matta <kelseymatta@gmail.com>; Kingsley Leggs <kingsleyleggs@gmail.com>; kristy <kristylee118@aol.com>; Krystal Sobaskie <krystal.sobaskie@gmail.com>; Kurt Perry <kurt.perry41@gmail.com>; Larissa Laurel <larissalaurel@gmail.com>; Lotte de Roy <lottederoy@hotmail.com>; Melvin Abston <melvin.abston@gmail.com>; Nancy Swiezy <nancyswiezyevents@gmail.com>; Nikki Stephenson <nikkistephenson12@gmail.com>; Patricia Einstein <yespatriciaeinstein@yahoo.com>; Paul Bolter <pbolter1@gmail.com>; Peter G <pgulczewski@gmail.com>; Rachel Leighson <rsmithweinstein@gmail.com>; Rita Rehn <ritarehn@aol.com>; Robert Matteau <bobby.matteau@icloud.com>; saundra_addison <saundra_addison@yahoo.com>; Standley McCray <standley.mccray@gmail.com>; Star Soriano <Starsoriano@gmail.com>; Stephanie Serfecz <stephanieserfecz@gmail.com>; Ted D'Ottavio <teddottavio@yahoo.com>; Triston John <trisjohn@gmail.com>; vanessa dawson <vanessagdawson@gmail.com>
