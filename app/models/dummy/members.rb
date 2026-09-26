module Dummy
  # People who can sign in, and the role that decides what they may change
  class Members
    # Columns of the per-page access toggles on Admin > Team & access
    PAGES = %w[health billing roadmap progress releases discussions ideas].freeze

    def initialize(data)
      @members = data[:members]
    end

    def all
      @members.map { |member| member.merge(demo: member.fetch(:demo, false)) }
    end

    def demo
      @members.select { |member| member[:demo] }.map { |member| member.slice(:name, :email, :role) }
    end

    # Unknown addresses still sign in, as read-only viewers.
    def find_or_guest(email)
      member = @members.find { |candidate| candidate[:email] == email }
      member || { name: email.split('@').first, email:, role: 'viewer' }
    end
  end
end
