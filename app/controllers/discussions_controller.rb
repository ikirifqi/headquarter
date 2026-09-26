# Meeting notes: a list on the side and the selected meeting in full
class DiscussionsController < InertiaController
  def index
    meetings = Dummy::Meetings.new(dummy)
    meeting = meetings.find(params.fetch(:id, meetings.latest[:id]).to_i)
    return head :not_found unless meeting

    render inertia: { meetings: meetings.list, meeting: }
  end
end
