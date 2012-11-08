class UsesController < ApplicationController
  def create
    @chemical = Chemical.find(params[:chemical_id])
    @use = @chemical.uses.create(params[:use])
    
    # reduce chemical amount according to use
    @chemical.amount = @chemical.amount - @use.amount
    @chemical.save
    
    redirect_to chemical_path(@chemical)
  end
end
