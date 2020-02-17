require File.expand_path('../../test_helper', __FILE__)

class ProductsControllerTest < ActionController::TestCase

  def test_index
  #  Role.find(1).add_permission! :view_products
    Project.find(1).enabled_module_names = [:warehouse]
    @request.session[:user_id] = 1

    get :index, params: {:project_id => 1}

    assert_response :success
    assert_template 'index'
  end

  def test_new
  #  Role.find(1).add_permission! :create_product
    Project.find(1).enabled_module_names = [:warehouse]
    @request.session[:user_id] = 1

    get :new, params: {:project_id => 1}

    assert_response :success
    assert_template 'new'
  end

end
