require File.expand_path('../../test_helper', __FILE__)

class ApplicationTypesControllerTest < ActionController::TestCase

  setup :with_unique_user

  test 'should show index with proper title' do
    get :index
    assert_response :success
    assert_select 'head title', 'OpenShift Origin'
  end

  test "should show index" do
    get :index
    assert_response :success
    assert types = assigns(:framework_types)
    assert types.length > 5
    assert types[0].name
    jboss_eap_seen = false
    types.each do |t|
      # check to make sure JBoss EAP comes before JBoss AS
      if t.id.start_with? 'jbosseap'
        jboss_eap_seen = true
      elsif t.id.start_with? 'jbossas'
        assert jboss_eap_seen, "Backend lists JBoss AS before JBoss EAP - EAP should take precidence"
      end
    end
  end

  test "should be able to find templates" do
    types = ApplicationType.all
    (templates,) = types.partition{|t| t.template}
    assert_not_equal 0, templates.length, "There should be templates to test against"
  end

  test "should show type page" do
    types = ApplicationType.all

    types.each do |t|
      get :show, :id => t.id
      assert_response :success
      assert type = assigns(:application_type)
      assert_equal t.name, type.name
      assert assigns(:application)
      assert_nil assigns(:domain)
      assert css_select('input#application_domain_name').present?
    end
  end

  test "should raise on missing type" do
    get :show, :id => 'missing_application_type'
    assert_response :success
    assert_select 'h1', /Application Type 'missing_application_type' does not exist/
  end

  test "should fill domain info" do
    with_unique_domain
    t = ApplicationType.all[0]

    get :show, :id => t.id
    assert_response :success
    assert type = assigns(:application_type)
    assert_equal t.name, type.name
    assert assigns(:application)
    assert domain = assigns(:domain)
    assert_equal @domain.id, domain.id
    assert css_select('input#application_domain_name').empty?
  end
end
