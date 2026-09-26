# Ideas board grouped by stage
class IdeasController < InertiaController
  def index
    ideas = Dummy::Ideas.new(dummy)

    render inertia: { stages: ideas.stages, ideas: ideas.all, link_options: ideas.link_options }
  end
end
