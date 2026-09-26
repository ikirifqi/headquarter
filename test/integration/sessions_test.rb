require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest
  test 'shows the demo accounts' do
    inertia_get '/login'

    assert_equal 'sessions/new', inertia_page['component']
    assert_equal 3, inertia_page.dig('props', 'demo_accounts').size
  end

  test 'signs a member in and shares who they are' do
    sign_in 'mira@halden.ai'

    assert_redirected_to root_path

    inertia_get '/'

    assert_equal({ 'name' => 'Mira Sato', 'email' => 'mira@halden.ai', 'role' => 'editor', 'first_name' => 'Mira' },
                 inertia_page.dig('props', 'current_user'))
  end

  test 'returns to the page the member came from' do
    post login_path, params: { email: 'dev@halden.ai', return_to: '/ideas' }

    assert_redirected_to '/ideas'
  end

  test 'ignores return paths on other hosts' do
    post login_path, params: { email: 'dev@halden.ai', return_to: 'https://evil.example/' }

    assert_redirected_to root_path
  end

  test 'rejects an invalid email' do
    post login_path, params: { email: 'not-an-email' }

    assert_redirected_to login_path
    assert_nil session[:email]
  end

  test 'signs out' do
    sign_in 'dev@halden.ai'
    delete logout_path

    assert_redirected_to root_path
    assert_nil session[:email]
  end
end
