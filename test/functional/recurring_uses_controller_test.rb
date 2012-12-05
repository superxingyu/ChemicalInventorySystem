require 'test_helper'

class RecurringUsesControllerTest < ActionController::TestCase
  
  setup do
    @chemical = chemicals(:one)
  end
  
  test "should create recurring use" do
    assert_difference('RecurringUse.count') do
      post :create, :recurring_use => { :chemist => "xingyu", :amount => 1000, :periodicity => "daily" }, :chemical_id => @chemical
    end
    assert_redirected_to chemical_path(assigns(:chemical))
  end
  
end
