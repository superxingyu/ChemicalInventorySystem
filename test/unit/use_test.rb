require 'test_helper'

class UseTest < ActiveSupport::TestCase
  
  test "should not save use without chemist" do
    use = Use.new(:chemist => nil, :amount => 50)
    assert !use.save, "Saved the use without a chemist."
  end
  
  test "should not save use without amount" do
    use = Use.new(:chemist => "Xingyu", :amount => nil)
    assert !use.save, "Saved the use without an amount."
  end
  
  test "should not save use if amount less than or equal to 0" do
    use = Use.new(:chemist => "Xingyu", :amount => 0)
    assert !use.save, "Saved the use with an amount of 0."
    use = Use.new(:chemist => "Xingyu", :amount => -1)
    assert !use.save, "Saved the use with an amount less than 0."
  end
  
  test "should not save if amount is larger than inventory" do
    chemical = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
    chemical.save
    use = chemical.uses.create(:chemist => "Xingyu", :amount => 600)
    assert !use.save, "Saved the use with an amount larger than inventory."
  end
  
end
