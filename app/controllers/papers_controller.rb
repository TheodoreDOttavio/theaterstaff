class PapersController < ApplicationController
  def index
  if current_user.admin?
    #Theater listing
    theaters = Theater.select(:id,:name)
    @theaters = []
    @theaters.push(["All Theaters",1])

    companies = companylist
    companies.each_with_index do |company,companyindex|
      @theaters.push(["All " + company[0] + " Theaters", company[1]])
    end

    theaters.each do |t|
      if t.id != 1 then
        @theaters.push([t.name,t.id])
      end
    end


    #for weekly output function
    @outputformat = []
    @outputformat.push(["PDF Cover Sheet",1])
    @outputformat.push(["MS Excell Files",2])


    #for monthly reports
    @allmonths = []
    astart = DateTime.now.utc.beginning_of_day
    for i in 1..700 do
      mystart = astart - i
      if mystart.strftime('%d') == '01' then
        if Distributed.datespan(mystart, (mystart+30)).infrared.exists? then
          @allmonths.push([mystart.strftime('%Y: %b'),mystart])
        end
      end
    end


    #for weekly xls reports and PDF cover sheets
    @allweeks = []
    for i in 1..100 do
      mystart = weekstart - (i * 7)
      myend = mystart + 6
      #check to see if there's any data at all on that week
      if Distributed.datespan(mystart, myend).infrared.exists? then
        @allweeks.push([mystart.strftime('%Y: %b %d')+" to "+ myend.strftime('%b %d'),mystart])
      end
    end
  else
    redirect_to root_url
  end
  end



  def generateweekly
    case params[:xportas]
      when "1"
        generateweeklypdf
      when "2"
        generateweeklyxls
      else
        flash[:error] = "Select A PDF cover sheet or a zip file of MS Excel documents for each theater"
    end
    redirect_to papers_path
  end



  def generatemonthly
  #to create MS Excell files
    require 'fileutils'
    require 'zip/zip'

    mystart = params[:xportmonthstart].to_date

    myend = (mystart + 1.months) - 1.days

    @monthof = mystart.strftime('%b - %Y')

    #clean up... remove existing xls files
    FileUtils.rm Dir.glob("app/reports/monthbytheater/*" + mystart.strftime('%b_%Y') + ".xls")
    FileUtils.rm Dir.glob("app/reports/month-by-theater_" + mystart.strftime('%b_%Y') + ".zip")

    #The performance list comes from distributed so closed shows, and no data shows are not included
    #  but... now chop down the remaining to limit by Theater company or theater
    case params[:xporttheater].to_f
      when 1 #all theaters
        performancelist = Distributed.allperformances(mystart, myend)
      when 0 #use theater company
        theater = Theater.where(company: params[:xporttheater])
        performancelist = []
        theater.each do |t|
          if !t.performance.nil? then
            performancelist.push(t.performance.id)
          end
        end
      else #theater_id was passed
        thistheaterid = params[:xporttheater].to_f
        theater = Theater.find(thistheaterid)
        if theater.performance.nil? then
          theater = Theater.where(company: params[:xporttheater])
          flash[:error] = "No Data Found for " + theater.name
          redirect_to papers_path
        else
          performancelist = Distributed.oneperformance(mystart, myend, theater)
        end
    end

    if !performancelist.nil? then
    #Make an exel doc for each theater
    performancelist.each do |p|

      @performance = Performance.find(p)
      @theater = Theater.find(@performance.theater_id)
      @distributeds = Distributed.infrared_for_oneperformance(mystart, myend, p)

      infrared = []
      translation = []
      icapdesc = []
      curtainlist = []

      #create excel file and spreadsheet
      # this writes everytime page is displayed to accomodate all changes and keep the link fresh
      workbook = WriteExcel.new('app/reports/monthbytheater/' + @theater.name + '_' + mystart.strftime('%b_%Y') + '.xls')
      worksheet  = workbook.add_worksheet

      # define formats for spreadsheet
      headerformat = workbook.add_format
      headerformat.set_font('Ariel')
      headerformat.set_size(12)
      headerformat.set_bold
      headerformat.set_color('blue')
      headerformat.set_align('left')

      keyformat = workbook.add_format
      keyformat.set_font('Times New Roman')
      keyformat.set_size(12)
      keyformat.set_color('black')
      keyformat.set_align('center')

      dayformat = workbook.add_format
      dayformat.set_font('Ariel')
      dayformat.set_size(11)
      dayformat.set_color('black')
      dayformat.set_align('left')

      dataformat = workbook.add_format
      dataformat.set_font('Times New Roman')
      dataformat.set_size(10)
      dataformat.set_color('black')
      dataformat.set_align('center')

      #set colums and row widths
      worksheet.set_column('A:B', 15)
      worksheet.set_column('C:E', 12)
      worksheet.set_row(0, 24)
      worksheet.print_area('A1:E16')

      #product_id 1 has all shows
      #build three vertical arrays of the quantities because each quantity is a group of product ID's or language ID's
      # The myspacer is for end of weektotals that move the rows down Starts at 2 for row 3
      myspacer = 2
      yesterdaywas = "Mon"
      toprowforweektotal = 3

      @distributeds.each_with_index do |u, ui|
        #is this entry going to be the first show of the week?
        #  if yesterday (last entry) was Fri, Sat or Sun then
        #  if this entry is Mon, Tue, or Wed... it IS - add two rows before continuing.
        sotodayis = u.curtain.strftime('%a')

        if yesterdaywas == 'Fri' or yesterdaywas == 'Sat' or yesterdaywas == 'Sun' then
          if sotodayis == 'Mon' or sotodayis == 'Tue' or sotodayis == 'Wed' then
            worksheet.write(ui+myspacer, 1, "Week Totals", keyformat)
            worksheet.write(ui+myspacer, 2, "=SUM(C" + toprowforweektotal.to_s + ":C" + (ui+myspacer).to_s + ")", keyformat)
            worksheet.write(ui+myspacer, 3, "=SUM(D" + toprowforweektotal.to_s + ":D" + (ui+myspacer).to_s + ")", keyformat)
            worksheet.write(ui+myspacer, 4, "=SUM(E" + toprowforweektotal.to_s + ":E" + (ui+myspacer).to_s + ")", keyformat)
            worksheet.set_row(ui+myspacer+1, 6)

            myspacer = myspacer + 2
            toprowforweektotal = ui + myspacer + 1
          end
        end
        yesterdaywas = u.curtain.strftime('%a')

        if u.eve == false then
          worksheet.write(ui+myspacer, 0, u.curtain.strftime('%A') + " mat", dayformat)
        else
          worksheet.write(ui+myspacer, 0, u.curtain.strftime('%A') + " eve", dayformat)
        end

        worksheet.write(ui+myspacer, 1, u.curtain.strftime('%m/%d/%Y'), dataformat)

        curtainlist.push([u.curtain,u.eve])

        #build up placeholder arrays for nil qty's...
        infrared.push(0)
        translation.push(0)
        icapdesc.push(0)

        #and drop in the week totals at the end:
        if ui == @distributeds.count-1 then
          worksheet.write(ui+myspacer+1, 1, "Week Totals", keyformat)
          worksheet.write(ui+myspacer+1, 2, "=SUM(C" + toprowforweektotal.to_s + ":C" + (ui+myspacer+1).to_s + ")", keyformat)
          worksheet.write(ui+myspacer+1, 3, "=SUM(D" + toprowforweektotal.to_s + ":D" + (ui+myspacer+1).to_s + ")", keyformat)
          worksheet.write(ui+myspacer+1, 4, "=SUM(E" + toprowforweektotal.to_s + ":E" + (ui+myspacer+1).to_s + ")", keyformat)
        end

        #Set the print Area and page formating
        worksheet.set_portrait
        worksheet.set_paper(1) # US letter size
        worksheet.center_horizontally
        worksheet.print_area(0,0,ui+myspacer+1, 4)
      end

      #infrared - add loops, and sanhausers product ID 1,3,6,7
      curtainlist.each_with_index do |u, ui|
        @distributeds = Distributed.where('performance_id = ? AND curtain = ? AND eve = ?', p, curtainlist[ui][0], curtainlist[ui][1]).infrared
        myqty = 0
        @distributeds.each do |d|
          myqty = myqty + d.quantity
        end
        infrared[ui] = infrared[ui] + myqty
      end

      #translations product ID 4,5 where languageID > 0
      curtainlist.each_with_index do |u, ui|
        @distributeds = Distributed.where('performance_id = ? AND curtain = ? AND eve = ?', p, curtainlist[ui][0], curtainlist[ui][1]).translation
        myqty = 0
        @distributeds.each do |d|
          myqty = myqty + d.quantity
        end
        translation[ui] = translation[ui] + myqty
      end

      #I-Cap & D.S product ID 4,5 where languageID = 0
      curtainlist.each_with_index do |u, ui|
        @distributeds = Distributed.where('performance_id = ? AND curtain = ? AND eve = ?', p, curtainlist[ui][0], curtainlist[ui][1]).icapdesc
        myqty = 0
        @distributeds.each do |d|
          myqty = myqty + d.quantity
        end
        icapdesc[ui] = icapdesc[ui] + myqty
      end

      #fill vertical colums
      # The myspacer is for end of weektotals that move the rows down Starts at 2 for row 3
      myspacer = 2
      yesterdaywas = "Mon"

      infrared.each_with_index do |qty,qtyi|
        sotodayis = curtainlist[qtyi][0].strftime('%a')
        if yesterdaywas == 'Fri' or yesterdaywas == 'Sat' or yesterdaywas == 'Sun' then
          if sotodayis == 'Mon' or sotodayis == 'Tue' or sotodayis == 'Wed' then
            myspacer = myspacer + 2
          end
        end
        yesterdaywas = curtainlist[qtyi][0].strftime('%a')

        worksheet.write(qtyi+myspacer, 2, infrared[qtyi], dataformat)
        worksheet.write(qtyi+myspacer, 3, translation[qtyi], dataformat)
        worksheet.write(qtyi+myspacer, 4, icapdesc[qtyi], dataformat)
      end

      #Static fields
      worksheet.write(0, 0, " " + @performance.name.upcase + " - " + @monthof, headerformat )
      worksheet.write(1, 2, "Infrared", keyformat)
      worksheet.write(1, 3, "Translation", keyformat)
      worksheet.write(1, 4, "I-Cap & D.S", keyformat)

     # write excell sheet to file
     workbook.close
   end

   excelfilelist = Dir.glob("app/reports/monthbytheater/*" + mystart.strftime('%b_%Y') + ".xls")

   if excelfilelist.empty? then
     flash[:error] = "No Data Found"
     redirect_to papers_path
   else
     #generate a zipfile and send it as a link
     zipfile_name = ("app/reports/month-by-theater_" + mystart.strftime('%b_%Y') + ".zip")
     folder = "app/reports/monthbytheater"

     Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
       excelfilelist.each do |filename|
         zipfile.add(filename.split("/")[3], filename)
       end
     end

     send_file zipfile_name, filename: zipfile_name.split("/")[3],
                         type: 'application/zip',
                         disposition: 'attachment'
   end
   end #end performance.nil?
end



private
  def generateweeklyxls
    #to create MS Excell files
    require 'fileutils'
    require 'zip/zip'

    mystart = params[:xportweekstart].to_date
    myend = mystart + 7.days

    @weekof = mystart.strftime('%a, %b %d - %Y')

    #clean up... remove existing xls files
    FileUtils.rm Dir.glob("app/reports/weekbytheater/*" + mystart.strftime('%Y_%m_%d') + ".xls")
    FileUtils.rm Dir.glob("app/reports/week-by-theater_" + mystart.strftime('%Y_%m_%d') + ".zip")

    performancelist = Distributed.datespan(mystart, myend).distinct(:performance_id).pluck(:performance_id)

    #Make an exel doc for each theater
    performancelist.each_with_index do |p, pi|

      @performance = Performance.find(p)
      @theater = Theater.find(@performance.theater_id)
      @distributeds = Distributed.datespan(mystart, myend).infrared.where('performance_id = ?', p).order(:curtain, :eve)

      infrared = []
      translation = []
      icapdesc = []
      curtainlist = []

      #create excel file and spreadsheet
      # this writes everytime page is displayed to accomodate all changes and keep the link fresh
      workbook = WriteExcel.new('app/reports/weekbytheater/' + @theater.name + '_' + mystart.strftime('%Y_%m_%d') + '.xls')
      worksheet  = workbook.add_worksheet

      # define formats for spreadsheet
      headerformat = workbook.add_format
      headerformat.set_font('Ariel')
      headerformat.set_size(12)
      headerformat.set_bold
      headerformat.set_color('blue')
      headerformat.set_align('left')

      keyformat = workbook.add_format
      keyformat.set_font('Times New Roman')
      keyformat.set_size(12)
      keyformat.set_color('black')
      keyformat.set_align('center')

      dayformat = workbook.add_format
      dayformat.set_font('Ariel')
      dayformat.set_size(11)
      dayformat.set_color('black')
      dayformat.set_align('left')

      dataformat = workbook.add_format
      dataformat.set_font('Times New Roman')
      dataformat.set_size(10)
      dataformat.set_color('black')
      dataformat.set_align('center')

      #set colums and row widths
      worksheet.set_column('A:B', 15)
      worksheet.set_column('C:E', 12)
      worksheet.set_row(0, 24)
      worksheet.print_area('A1:E16')

      #product_id 1 has all shows
      #build three vertical arrays of the quantities because each quantity is a group of product ID's or language ID's
      @distributeds.each_with_index do |u, ui|
        if u.eve == false then
          worksheet.write(ui+2, 0, u.curtain.strftime('%A') + " mat", dayformat)
        else
          worksheet.write(ui+2, 0, u.curtain.strftime('%A') + " eve", dayformat)
        end

        worksheet.write(ui+2, 1, u.curtain.strftime('%m/%d/%Y'), dataformat)

        curtainlist.push([u.curtain,u.eve])

        infrared.push(0)
        translation.push(0)
        icapdesc.push(0)
      end


      ####THIS. seems to be assembling the vert colums wrong...


      #infrared - add loops, and sanhausers product ID 1,3,6,7
      curtainlist.each_with_index do |u, ui|
        @distributeds = Distributed.where('performance_id = ? AND curtain = ? AND eve = ?', p, curtainlist[ui][0], curtainlist[ui][1]).infrared
        myqty = 0
        @distributeds.each do |d|
          myqty = myqty + d.quantity
        end
        infrared[ui] = infrared[ui] + myqty
      end

      #translations product ID 4,5 where languageID > 0
      curtainlist.each_with_index do |u, ui|
        @distributeds = Distributed.where('performance_id = ? AND curtain = ? AND eve = ?', p, curtainlist[ui][0], curtainlist[ui][1]).translation
        myqty = 0
        @distributeds.each do |d|
          myqty = myqty + d.quantity
        end
        translation[ui] = translation[ui] + myqty
      end

      #I-Cap & D.S product ID 4,5 where languageID = 0
      curtainlist.each_with_index do |u, ui|
        @distributeds = Distributed.where('performance_id = ? AND curtain = ? AND eve = ?', p, curtainlist[ui][0], curtainlist[ui][1]).icapdesc
        myqty = 0
        @distributeds.each do |d|
          myqty = myqty + d.quantity
        end
        icapdesc[ui] = icapdesc[ui] + myqty
      end

      #fill vertical colums
      infrared.each_with_index do |qty,qtyi|
        worksheet.write(qtyi+2, 2, infrared[qtyi], dataformat)
        worksheet.write(qtyi+2, 3, translation[qtyi], dataformat)
        worksheet.write(qtyi+2, 4, icapdesc[qtyi], dataformat)
      end

      #Static fields
      worksheet.write(0, 0, " " + @performance.name.upcase + " - Translations,  + D-Script and I-Cap -  Week of " + @weekof, headerformat )
      worksheet.write(1, 2, "Infrared", keyformat)
      worksheet.write(1, 3, "Translation", keyformat)
      worksheet.write(1, 4, "I-Cap & D.S", keyformat)

      worksheet.write(14, 1, "Week Totals", keyformat)
      worksheet.write(14, 2, "=SUM(C3:C13)", dataformat)
      worksheet.write(14, 3, "=SUM(D3:D13)", dataformat)
      worksheet.write(14, 4, "=SUM(E3:E13)", dataformat)

        #Set the print Area and page formating
        worksheet.set_portrait
        worksheet.set_paper(1) # US letter size
        worksheet.center_horizontally
        worksheet.print_area(0,0,15,4)

     # write excell sheet to file
     workbook.close
   end

   excelfilelist = Dir.glob("app/reports/weekbytheater/*" + mystart.strftime('%Y_%m_%d') + ".xls")

   if excelfilelist.empty? then
     flash[:error] = "No Data Found for the week of " + @weekof
     redirect_to papers_path
   else
     #generate a zipfile and send it as a link
     zipfile_name = ("app/reports/week-by-theater_" + mystart.strftime('%Y_%m_%d') + ".zip")
     folder = "app/reports/weekbytheater"

     Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
       excelfilelist.each do |filename|
         zipfile.add(filename.split("/")[3], filename)
       end
     end

     send_file zipfile_name, filename: zipfile_name.split("/")[3],
                         type: 'application/zip',
                         disposition: 'attachment'
   end


  end



  def generateweeklypdf
      #Build a PDF....

      mystart = params[:xportweekstart].to_date
      myend = mystart + 7

      #Make a list of performances
      myshows = Distributed.datespan(mystart, myend).joins(:performance).order('name').select('name', :performance_id).distinct
      totaldistributed = Array.new(11, 0)

      report = ThinReports::Report.new layout: File.join(Rails.root, 'app', 'reports', 'showweek.tlf')
      report.start_new_page

      report.page.item(:weekof).value(mystart.strftime('%b %d, %Y'))

      myshows.each do |show|
        producttotals = []

        report.list.add_row do |row|
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [1,6], 0))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [3,7], 0))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, 5, 1))
          #[3] descriptive on r4 and comtek
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 2))
          #[4] chinese - languages are listed (commented out in seeds.db)
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 3))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 4))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 5))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 6))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 7))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 8))
          producttotals.push(weeklyproductcounter(mystart, myend, show.performance.id, [4,5], 9))

          #add this up for totals in the footer
          totaldistributed.count.times do |t|
            if producttotals[t] != nil then
              totaldistributed[t] = producttotals[t].to_i + totaldistributed[t]
            end
          end

          #write the values to the pdf
          row.values theater: show.performance.theater.name,
                     performance: show.performance.name,
                     headsets: producttotals[0],
                     loops: producttotals[1],
                     icap: producttotals[2],
                     desc: producttotals[3],
                     chi: producttotals[4],
                     fre: producttotals[5],
                     ger: producttotals[6],
                     jpn: producttotals[7],
                     ptg: producttotals[8],
                     spn: producttotals[9],
                     tur: producttotals[10]
          end
      end

      #and write the totals
      report.page.item(:totheadsets).value(totaldistributed[0])
      report.page.item(:totloops).value(totaldistributed[1])
      report.page.item(:toticap).value(totaldistributed[2])
      report.page.item(:totdesc).value(totaldistributed[3])
      report.page.item(:totchi).value(totaldistributed[4])
      report.page.item(:totfre).value(totaldistributed[5])
      report.page.item(:totger).value(totaldistributed[6])
      report.page.item(:totjpn).value(totaldistributed[7])
      report.page.item(:totptg).value(totaldistributed[8])
      report.page.item(:totspn).value(totaldistributed[9])
      report.page.item(:tottur).value(totaldistributed[10])

      send_data report.generate, filename: "datacoversheet_" + mystart.strftime('%Y_%m_%d') + ".pdf",
                                 type: 'application/pdf',
                                 disposition: 'attachment'
    end


    def weeklyproductcounter (mystart, myend, myperformance_id, myproduct_id, mylanguage_id)
      headsets = Distributed.datespan(mystart, myend).select(:quantity).where(product_id: myproduct_id, language: mylanguage_id, performance_id: myperformance_id)
      thisvalue = 0
      headsets.each do |d|
        thisvalue = thisvalue + d.quantity
      end
      if thisvalue == 0 then
          return "."
        else
          return thisvalue
      end
    end
end