require 'test_helper'

class HomepageLayoutTest < ActionDispatch::IntegrationTest
  test "the truth" do
    assert true
  end
  
  test "homepage links" do
  	get root_path
  	assert_template 'pages/home'
  end
end
