module Dummy
  # Meeting notes with summaries, decisions, action items and transcripts
  class Meetings
    def initialize(data)
      @meetings = data[:meetings]
      @project_names = data[:projects].to_h { |project| [project[:id], project[:name]] }
    end

    def all
      @meetings.sort_by { |meeting| meeting[:date] }.reverse.map { |meeting| with_project_name(meeting) }
    end

    def list
      all.map { |meeting| meeting.slice(:id, :date, :title, :project_name) }
    end

    def find(id)
      all.find { |meeting| meeting[:id] == id }
    end

    def latest
      all.first
    end

    private

    def with_project_name(meeting)
      meeting.merge(project_name: @project_names.fetch(meeting[:project], 'All'))
    end
  end
end
