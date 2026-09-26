# Roadmap, progression and releases for one project at a time
class ProjectsController < InertiaController
  before_action :set_project

  def roadmap
    timeline = @projects.timeline

    render inertia: project_props.merge(
      months: timeline.months,
      today_offset: timeline.today_offset,
      milestones: timeline.milestones(@project)
    )
  end

  def progress
    render inertia: project_props.merge(epics: @projects.epics(@project))
  end

  def releases
    render inertia: project_props.merge(releases: @projects.releases(@project))
  end

  private

  def set_project
    @projects = Dummy::Projects.new(dummy)
    @project = @projects.find(params.fetch(:project_id, @projects.ids.first))
    head :not_found unless @project
  end

  def project_props
    { project: @projects.overview(@project), projects: @projects.tabs }
  end
end
