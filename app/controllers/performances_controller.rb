class PerformancesController < ApplicationController
  def index
    if params[:current] == "1" then
      @title = "Now Showing"
      @performances = Performance.nowshowing.paginate(page: params[:page]).order(:name)
    else
      @title = "All Shows"
      @performances = Performance.paginate(page: params[:page]).order(:name)
    end
  end
  

  def show
    #profile page for a single show
    @performance = Performance.find(params[:id])

    #Sample for the chartkick gem
    #    <%= line_chart [
    #  {name: "Teacher", data: current_user.timesheets.map{|t| [t.day, t.teacher] }},
    #  {name: "Study", data: current_user.timesheets.map{|t| [t.day, t.study] }},
    #  {name: "Conversation", data: current_user.timesheets.map{|t| [t.day, t.conversation] }}
    #    ] %>

    @mychart = []
    thisshowproductlist = Distributed.where(performance_id: params[:id]).group(:product_id)
    thisshowproductlist.each do |p|
      @mychart.push({name: p.product.name.to_s,
        data: Distributed.where(performance_id: params[:id], product_id: p.product_id).map{
          |t| [t.curtain, t.quantity]}
        })
    end

    #and Chartkick uses a google service which is annoying
    #   to wait for when you're on a completely unrelated page.
    #   sooo... this global is checked in application.html.erb
    @princess_gem_needs_her_internet = true
  end


  def new
    @performance = Performance.new
    @anopeningdate = weekstart
  end


  def create
    @performance = Performance.new(performance_params)
    if @performance.save
      flash[:success] = "A new Show has been added!"
      redirect_to performances_path
    else
      render 'new'
    end
  end


  def edit
    @performance = Performance.find(params[:id])
    mylastDistributed = Distributed.select(:curtain).where('performance_id = ?', @performance.id).order(:curtain)
    if mylastDistributed.count == 0 then
      @mylastDistributed = weekstart
    else
      @mylastDistributed = mylastDistributed.last.curtain
    end
  end


  # def editforschedule #changed handler to make a route later
    # mystart = weekstart
    # @performance = Performance.find(params[:id],
      # :include => :events,
      # :order => 'events.curtain',
      # :conditions => ['events.curtain > ?', mystart])
# 
    # #to filter by availability
    # @users = User.all.order(:name)
# 
    # @mydatearray = []
    # @mydate = DateTime.new
# 
    # @curtains = Curtains.all.order(:set,:hrmin)
# 
    # @daysoftheweek = {}
    # (0..6).each do |d|
      # @daysoftheweek[(mystart + d.days).strftime('%a')] = d
    # end
    # @curtaintime = {}
    # @curtainselectedday = {}
    # @curtainselectedtime = {}
# 
    # @performance.events.each do |p|
      # if p.curtain.strftime('%I').to_f > 4 then
        # @curtaintime[p.curtain] = p.curtain.strftime('%a') + " E - " + p.curtain.strftime('%a %m/%d')
      # else
        # @curtaintime[p.curtain] = p.curtain.strftime('%a') + " M - " + p.curtain.strftime('%a %m/%d')
      # end
# 
      # #Formatted DateTime stamps
      # @curtainselectedday[p.curtain] = p.curtain.strftime('%a')
      # @curtainselectedtime[p.curtain] = p.curtain.strftime('%H:%M')
    # end
  # end


  def update
    @performance = Performance.find(params[:id])
    if @performance.update_attributes(performance_params)
      flash[:success] = "Show Information has been Updated"
      redirect_to performances_path(current: 1)
    else
      render 'edit'
    end
  end


  def destroy
    @performance = Performance.find(params[:id])
    Performance.find(params[:id]).destroy
    flash[:success] = @performance.name + " has been Deleted."
    redirect_to performances_path
  end
end