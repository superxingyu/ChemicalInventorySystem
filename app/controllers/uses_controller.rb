class UsesController < ApplicationController
  
  # POST [chemical_id]/uses
  def create
    @chemical = Chemical.find(params[:chemical_id])
    @use = @chemical.uses.create(params[:use])

    if @use.errors.any?
      notice = @use.errors.full_messages()[0] 
    else
      notice = 'Use of chemical was successfully recorded'
    end
    
    respond_to do |format|
      format.html { redirect_to @chemical, :notice => notice }
    end
  end
end
