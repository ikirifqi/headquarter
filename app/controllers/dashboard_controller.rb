# Landing page: one card per area with the headline number from each
class DashboardController < InertiaController
  def show
    render inertia: health_props.merge(project_props).merge(
      due_soon: Dummy::Billing.new(dummy).due_soon,
      latest_meeting: Dummy::Meetings.new(dummy).latest.slice(:id, :date, :title, :summary, :attendees),
      idea_stages: Dummy::Ideas.new(dummy).stage_counts
    )
  end

  private

  def health_props
    health = Dummy::Health.new(dummy)

    {
      services: health.services.map { |service| service.slice(:name, :status) },
      health: health.overview,
      open_incident: health.open_incident
    }
  end

  def project_props
    projects = Dummy::Projects.new(dummy)

    { project_cards: projects.cards, latest_release: projects.latest_release }
  end
end
