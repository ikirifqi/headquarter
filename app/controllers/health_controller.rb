# Service uptime, background job queues and the incident log
class HealthController < InertiaController
  def show
    health = Dummy::Health.new(dummy)

    render inertia: {
      health: health.overview,
      services: health.services,
      queues: health.queues,
      incidents: health.incidents
    }
  end
end
