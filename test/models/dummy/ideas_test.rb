require 'test_helper'

module Dummy
  class IdeasTest < ActiveSupport::TestCase
    setup { @ideas = Ideas.new(Dummy.data) }

    test 'resolves links to the pages they point at' do
      links = @ideas.all.find { |idea| idea[:id] == 3 }[:links]

      assert_equal [
        { kind: 'discussion', label: 'Q3 review with the board', href: '/discussions/1' },
        { kind: 'ticket', label: 'SCT-104 Cost report per provider', chip: 'SCT-104', href: '/progress/scout' }
      ], links
    end

    test 'counts ideas per stage in board order' do
      counts = @ideas.stage_counts

      assert_equal %w[new reviewing accepted progress shipped], counts.pluck(:id)
      assert_equal [2, 2, 1, 1, 1], counts.pluck(:count)
    end

    test 'offers only open tickets in the link picker' do
      labels = @ideas.link_options[:tickets].pluck(:label)

      assert_includes labels, 'SCT-104 Cost report per provider'
      assert_not_includes labels, 'SCT-101 Health scoring per provider'
    end
  end
end
