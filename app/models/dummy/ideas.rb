module Dummy
  # The ideas board, with links resolved to the pages they point at
  class Ideas
    include Rails.application.routes.url_helpers

    def initialize(data)
      @data = data
      @projects = Projects.new(data)
      @meetings = Meetings.new(data)
    end

    def stages
      @data[:idea_stages]
    end

    def all
      @data[:ideas].map do |idea|
        idea.merge(
          tags: idea.fetch(:tags, []),
          comments: idea.fetch(:comments, []),
          links: idea.fetch(:links, []).filter_map { |link| resolve(link) }
        )
      end
    end

    def stage_counts
      ideas = @data[:ideas]
      stages.map { |stage| stage.merge(count: ideas.count { |idea| idea[:stage] == stage[:id] }) }
    end

    # Everything an idea can be linked to from the link picker
    def link_options
      {
        projects: @projects.ids.map { |id| resolve(project: id, page: 'roadmap').merge(meta: 'Project') },
        discussions: @meetings.all.map { |meeting| resolve(meeting: meeting[:id]).merge(meta: meeting[:date]) },
        tickets: open_tickets.map { |ticket| resolve(ticket: ticket[:id]).merge(meta: ticket[:project_name]) }
      }
    end

    private

    def open_tickets
      @projects.tickets.reject { |ticket| ticket[:status] == 'done' }
    end

    def resolve(link)
      if link[:ticket] then ticket_link(link[:ticket])
      elsif link[:meeting] then meeting_link(link[:meeting])
      elsif link[:project] then project_link(link)
      end
    end

    def project_link(link)
      project = @projects.find(link[:project])
      return unless project

      page = link.fetch(:page, 'roadmap')
      { kind: 'project', label: link[:label] || project[:name], href: public_send("#{page}_path", project[:id]) }
    end

    def meeting_link(id)
      meeting = @meetings.find(id)
      return unless meeting

      { kind: 'discussion', label: meeting[:title], href: discussions_path(id) }
    end

    def ticket_link(id)
      ticket = @projects.tickets.find { |candidate| candidate[:id] == id }
      return unless ticket

      { kind: 'ticket', label: "#{id} #{ticket[:title]}", chip: id, href: progress_path(ticket[:project_id]) }
    end
  end
end
