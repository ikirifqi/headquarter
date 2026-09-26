module Dummy
  # Projects with their roadmap milestones, epics and tasks, and release notes
  class Projects
    TASK_NUMBER_START = 101

    def initialize(data)
      @data = data
      @projects = data[:projects]
    end

    def ids
      @projects.pluck(:id)
    end

    def tabs
      @projects.map { |project| project.slice(:id, :name) }
    end

    def find(id)
      @projects.find { |project| project[:id] == id }
    end

    def overview(project)
      project.slice(:id, :name, :description, :current_epic, :next_deliverable, :next_date)
    end

    # Epics with ticket ids assigned in order: ATL-101, ATL-102, ...
    def epics(project)
      number = TASK_NUMBER_START - 1
      project[:epics].map do |epic|
        tasks = epic[:tasks].map do |task|
          number += 1
          task.merge(id: "#{project[:prefix]}-#{number}", owner: task[:owner])
        end
        { name: epic[:name], tasks: }
      end
    end

    def tickets
      @projects.flat_map do |project|
        epics(project).flat_map do |epic|
          epic[:tasks].map { |task| task.merge(project_id: project[:id], project_name: project[:name]) }
        end
      end
    end

    def cards
      @projects.map do |project|
        overview(project).merge(done_percent: done_percent(epics(project).flat_map { |epic| epic[:tasks] }))
      end
    end

    def done_percent(tasks)
      return 0 if tasks.empty?

      (tasks.count { |task| task[:status] == 'done' } * 100.0 / tasks.size).round
    end

    def releases(project)
      project[:releases]
    end

    def latest_release
      releases = @projects.flat_map do |project|
        project[:releases].map { |release| release.merge(project_id: project[:id], project_name: project[:name]) }
      end
      releases.max_by { |release| release[:date] }
    end

    def timeline
      Timeline.new(@data)
    end
  end
end
