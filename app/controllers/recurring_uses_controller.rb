class RecurringUsesController < ApplicationController
  
  # POST [chemical_id]/recurring_uses
  def create
    @chemical = Chemical.find(params[:chemical_id])
    
    # TEMP CODE
    err = false
    recurring_use_data = params[:recurring_use]
    end_date_s = recurring_use_data["end_date"]
    end_date = nil
    if end_date_s.nil? || end_date_s.length == 0
      # no end date
      end_date = nil
    else
      begin
        end_date = Date.parse(end_date_s)
      rescue
        notice = 'Wrong date format'
        err = true
      end
    end
    
    if !err
      recurring_use_data["end_date"] = end_date
      
      @recurring_use = @chemical.recurring_uses.create(recurring_use_data)
      
      if @recurring_use.errors.any?
        notice = @recurring_use.errors.full_messages()[0] 
      else
        notice = 'Recurring Use of chemical was successfully recorded'
      end
    end
    
    respond_to do |format|
      format.html { redirect_to @chemical, :notice => notice }
    end
  end
  
end
