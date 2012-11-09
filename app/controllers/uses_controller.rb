class UsesController < ApplicationController
  def create
    @chemical = Chemical.find(params[:chemical_id])
    
    use_data = params[:use]
    use_amount = use_data[:amount].to_i
    
    if @chemical.amount < use_amount
      redirect_to chemical_path(@chemical), :notice => "Amount is not enough."
    else
      @use = @chemical.uses.create(use_data)
      
      # update chemical amount after use
      @chemical.amount = @chemical.amount - @use.amount
      @chemical.save
      
      redirect_to chemical_path(@chemical)
    end
  end
end
