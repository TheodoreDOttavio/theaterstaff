class DistributedReportsController < ApplicationController

  def index
    @distributed_report = DistributedReport.new(params[:distributed_report])

    respond_to do |f|
      f.html do
        @distributed_report.scope {|scope| scope.page(params[:page]) }
      end
      f.csv do
        send_data @distributed_report.to_csv,
          type: "text/csv",
          disposition: 'inline',
          filename: "grid-#{Time.now.to_s}.csv"
      end
    end

  end

end