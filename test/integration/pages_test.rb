require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  test 'every page is readable without signing in' do
    {
      '/' => 'dashboard/show',
      '/health' => 'health/show',
      '/billing' => 'billing/show',
      '/roadmap' => 'projects/roadmap',
      '/progress/relay' => 'projects/progress',
      '/releases/scout' => 'projects/releases',
      '/discussions' => 'discussions/index',
      '/discussions/3' => 'discussions/index',
      '/ideas' => 'ideas/index'
    }.each do |path, component|
      inertia_get path

      assert_response :success, path
      assert_equal component, inertia_page['component'], path
      assert_nil inertia_page.dig('props', 'current_user')
    end
  end

  test 'project pages default to the first project' do
    inertia_get '/roadmap'

    assert_equal 'atlas', inertia_page.dig('props', 'project', 'id')
    assert_equal 6, inertia_page.dig('props', 'milestones').size
  end

  test 'discussions show the chosen meeting' do
    inertia_get '/discussions/3'

    assert_equal 'Provider failover design', inertia_page.dig('props', 'meeting', 'title')
  end

  test 'unknown projects and meetings are not found' do
    inertia_get '/progress/nope'

    assert_response :not_found

    inertia_get '/discussions/99'

    assert_response :not_found
  end
end
