class RecurringUsesController < ApplicationController
  
  # POST [chemical_id]/recurring_uses
  def create
    @chemical = Chemical.find(params[:chemical_id]) 
    @recurring_use = @chemical.recurring_uses.create(params[:recurring_use])
    
    if @recurring_use.errors.any?
      notice = @recurring_use.errors.full_messages()[0] 
    else
      notice = 'Recurring Use of chemical was successfully recorded'
    end
    
    respond_to do |format|
      format.html { redirect_to @chemical, :notice => notice }
    end
  end
  
end
