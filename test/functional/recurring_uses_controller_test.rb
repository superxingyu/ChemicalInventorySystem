require 'test_helper'

class RecurringUsesControllerTest < ActionController::TestCase
  
  setup do
    @chemical = chemicals(:one)
  end
  
  test "should create recurring use" do
    assert_difference('RecurringUse.count') do
      post :create, :recurring_use => { :chemist => "Xingyu", :amount => 1000, :periodicity => "daily" }, :chemical_id => @chemical
    end
    assert_redirected_to chemical_path(assigns(:chemical))
    
    assert_difference('RecurringUse.count') do
      post :create, :recurring_use => { :chemist => "Xingyu", :amount => 1000, :periodicity => "weekly", 
        :first_effective_date => "2012-08-08", :end_date => "2012-09-08"}, :chemical_id => @chemical
    end
    assert_redirected_to chemical_path(assigns(:chemical))
  end
  
  test "should not create recurring use if end date format is wrong" do
    assert_no_difference('RecurringUse.count') do
      post :create, :recurring_use => { :chemist => "Xingyu", :amount => 120, :periodicity => "weekly", 
        :first_effective_date => "2012-08-08", :end_date => "2012090"}, :chemical_id => @chemical
    end
    assert_redirected_to chemical_path(assigns(:chemical))
    
    assert_no_difference('RecurringUse.count') do
      post :create, :recurring_use => { :chemist => "Xingyu", :amount => 120, :periodicity => "weekly", 
        :first_effective_date => "2012-08-08", :end_date => "AAAA"}, :chemical_id => @chemical
    end
    assert_redirected_to chemical_path(assigns(:chemical))
  end
  
end
