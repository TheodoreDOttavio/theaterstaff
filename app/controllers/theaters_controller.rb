class TheatersController < ApplicationController
  def show
    @theater = Theater.find(params[:id])
  end


  def index
    @theaters = Theater.order(:name).paginate(page: params[:page])
  end


  def new
    @theater = Theater.new
    @companies = companylist
  end


  def create
    @theater = Theater.new
    @companies = companylist
    if @theater.save
      flash[:success] = "A new Theater/Venue has been added!"
      redirect_to @theater
    else
      render 'new'
    end
  end


  def edit
    @theater = Theater.find(params[:id])
    @companies = companylist
    @performances = Performance.all.order(:name)
  end


  def update
    @theater = Theater.find(params[:id])
    @companies = companylist
    if @theater.update_attributes(params)
      flash[:success] = "Theater/Venue Information has been Updated"
      redirect_to theaters_path
    else
      render 'edit'
    end
  end


  def destroy
    Theater.find(params[:id]).destroy
    flash[:success] = "Theater/Venue has been deleted."
    redirect_to theaters_path
  end

end