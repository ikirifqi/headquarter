# Sources, vendor logins, API access and team roles. Nothing is sent unless the member is an admin.
class AdminController < InertiaController
  def show
    return render inertia: 'admin/locked' unless admin?

    admin = Dummy::Admin.new(dummy)

    render inertia: {
      integrations: admin.integrations,
      manual_entries: admin.manual_entries,
      bills: admin.bills,
      vendors: admin.vendors,
      api: admin.api,
      team: { members: admin.members, pages: Dummy::Members::PAGES }
    }
  end
end
