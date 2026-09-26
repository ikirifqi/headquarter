require 'test_helper'

module Dummy
  class ProjectsTest < ActiveSupport::TestCase
    setup do
      @data = Dummy.data
      @projects = Projects.new(@data)
    end

    test 'assigns ticket ids per project in epic order' do
      tasks = @projects.epics(@projects.find('scout')).flat_map { |epic| epic[:tasks] }

      assert_equal %w[SCT-101 SCT-102 SCT-103 SCT-104], tasks.first(4).pluck(:id)
      assert_equal 'Cost report per provider', tasks.fourth[:title]
    end

    test 'reports the share of done tasks on each card' do
      assert_equal({ 'atlas' => 30, 'relay' => 29, 'scout' => 14 },
                   @projects.cards.to_h { |card| [card[:id], card[:done_percent]] })
    end

    test 'picks the most recent release across projects' do
      release = @projects.latest_release

      assert_equal %w[2.14.1 atlas], release.values_at(:version, :project_id)
    end

    test 'positions milestones as percentages of the timeline' do
      first = @projects.timeline.milestones(@projects.find('atlas')).first

      assert_in_delta 0.0, first[:offset]
      assert_in_delta 15.47, first[:span]
    end

    test 'marks today on a six month timeline' do
      timeline = @projects.timeline

      assert_in_delta 7.73, timeline.today_offset
      assert_equal Date.new(2027, 2, 1), timeline.months.last
    end
  end
end
