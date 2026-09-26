module Dummy
  # Sources, manual entries, vendor logins, API access and team roles. Admin sessions only.
  class Admin
    def initialize(data)
      @data = data
      @admin = data[:admin]
    end

    def integrations
      @admin[:integrations]
    end

    def manual_entries
      @admin[:manual_entries].map do |area|
        area.merge(placeholder: area.fetch(:placeholder, ''), items: area.fetch(:items, []))
      end
    end

    # Newest first, so entries added by hand sit at the top of the list
    def bills
      Billing.new(@data).bills.reverse
    end

    def vendors
      @admin[:vendors].each_with_index.map { |vendor, index| vendor.merge(id: index + 1) }
    end

    def api
      api = @admin[:api]
      api.merge(keys: api[:keys].each_with_index.map { |key, index| key.merge(id: index + 1) })
    end

    def members
      Members.new(@data).all
    end
  end
end
