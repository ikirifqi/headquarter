require 'test_helper'

module Dummy
  class MembersTest < ActiveSupport::TestCase
    setup { @members = Members.new(Dummy.data) }

    test 'finds a member by email' do
      assert_equal 'admin', @members.find_or_guest('dev@halden.ai')[:role]
    end

    test 'treats unknown addresses as viewers' do
      assert_equal({ name: 'someone', email: 'someone@example.com', role: 'viewer' },
                   @members.find_or_guest('someone@example.com'))
    end

    test 'lists demo accounts without their page access' do
      assert_equal %w[r.okafor@board.halden.ai mira@halden.ai dev@halden.ai], @members.demo.pluck(:email)
      assert(@members.demo.none? { |member| member.key?(:pages) })
    end
  end
end
