class UsesController < ApplicationController
  
  # POST [chemical_id]/uses
  def create
    @chemical = Chemical.find(params[:chemical_id])
    
    failed = false
    begin
      @use = @chemical.uses.create(params[:use])
      if @use.errors.any?
        failed = true
        # just show the first error
        notice = @use.errors.full_messages()[0]
      else
        notice = 'Use of chemical was successfully recorded'
      end
    rescue Exception => e
      notice = 'Not enough chemical to use'
      failed = true
    end
    
    respond_to do |format|
      format.html { redirect_to @chemical, :notice => notice }
    end
  end
end
