class ScansController < ApplicationController
  def index
    if !current_user.admin?
      redirect_to root_url
    end
  end


  def sort
  if current_user.admin?
    #Performances
    @performances = Performance.select(:name, :id).order(:name)

    #Type of paperwork being uploaded
    @paperworkformat = []
    @paperworkformat.push(["Infrared Daily Log",1])
    @paperworkformat.push(["Special Services Log ",2])

    #for weekly xls reports and PDF cover sheets
    @completeweeks = Distributed.completeweeks(weekstart)

    @thisfilename = params[:Data].original_filename
    @thisimage = params[:Data].tempfile

    #if !File.exist?(uploaded_io.tempfile) then
      #flash[:error] = "File did not open!"
      #@test = uploaded_io
      #redirect_to archives_restore
      #return
    #end

  else
    redirect_to root_url
  end
  end


end