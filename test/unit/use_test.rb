require 'test_helper'

class UseTest < ActiveSupport::TestCase
  
  test "should not save use without chemist" do
    @chemical = chemicals(:one)
    use = @chemical.uses.create(:chemist => nil, :amount => 50)
    assert !use.save, "Saved the use without a chemist."
  end
  
  test "should not save use without amount" do
    @chemical = chemicals(:one)
    use = @chemical.uses.create(:chemist => "Xingyu", :amount => nil)
    assert !use.save, "Saved the use without an amount."
  end
  
  test "should not save use if amount less than or equal to 0" do
    @chemical = chemicals(:one)
    use1 = @chemical.uses.create(:chemist => "Xingyu", :amount => 0)
    assert !use1.save, "Saved the use with an amount of 0."
    use2 = @chemical.uses.create(:chemist => "Xingyu", :amount => -1)
    assert !use2.save, "Saved the use with an amount less than 0."
  end
  
  test "should not save if amount is larger than inventory" do
    @chemical = chemicals(:one)
    use = @chemical.uses.create(:chemist => "Xingyu", :amount => 5200)
    assert !use.save, "Saved the use with an amount larger than inventory."
  end
    
  describe "deduct_chemical_amount_after_use" do
    it "should deduct used amount" do
      chemical = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
      chemical.uses.create(:chemist => "Xingyu", :amount => 50)
      use.chemical.should_receive(:update_attributes)
    end
  end
    
end
