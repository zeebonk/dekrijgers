require 'test_helper'

class FeaturedItemsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:featured_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create featured_item" do
    assert_difference('FeaturedItem.count') do
      post :create, :featured_item => { }
    end

    assert_redirected_to featured_item_path(assigns(:featured_item))
  end

  test "should show featured_item" do
    get :show, :id => featured_items(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => featured_items(:one).to_param
    assert_response :success
  end

  test "should update featured_item" do
    put :update, :id => featured_items(:one).to_param, :featured_item => { }
    assert_redirected_to featured_item_path(assigns(:featured_item))
  end

  test "should destroy featured_item" do
    assert_difference('FeaturedItem.count', -1) do
      delete :destroy, :id => featured_items(:one).to_param
    end

    assert_redirected_to featured_items_path
  end
end
