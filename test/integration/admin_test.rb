require 'test_helper'

class AdminTest < ActionDispatch::IntegrationTest
  test 'is locked for visitors without sending any admin data' do
    inertia_get '/admin'

    assert_equal 'admin/locked', inertia_page['component']
    assert_not_includes response.body, 'Tq7!vLm2#pRx9wZe'
  end

  test 'is locked for editors' do
    sign_in 'mira@halden.ai'
    inertia_get '/admin'

    assert_equal 'admin/locked', inertia_page['component']
  end

  test 'shows sources, vendors, API access and the team to admins' do
    sign_in 'dev@halden.ai'
    inertia_get '/admin'

    assert_equal 'admin/show', inertia_page['component']
    assert_equal({ 'integrations' => 6, 'vendors' => 9, 'keys' => 3, 'members' => 5 },
                 'integrations' => inertia_page.dig('props', 'integrations').size,
                 'vendors' => inertia_page.dig('props', 'vendors').size,
                 'keys' => inertia_page.dig('props', 'api', 'keys').size,
                 'members' => inertia_page.dig('props', 'team', 'members').size)
  end
end
