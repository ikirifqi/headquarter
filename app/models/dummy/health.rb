module Dummy
  # Service uptime, background queues and the incident log
  class Health
    def initialize(data)
      @data = data
      @today = data.dig(:organization, :today)
    end

    def services
      @data[:services].map do |service|
        history = service[:history].each_with_index.map do |status, index|
          { date: @today - (service[:history].size - 1 - index), status: }
        end
        service.merge(history:)
      end
    end

    def queues
      @data[:queues]
    end

    def incidents
      @data[:incidents]
    end

    def open_incident
      incidents.find { |incident| incident[:state] != 'resolved' }
    end

    def overview
      {
        degraded: @data[:services].count { |service| service[:status] != 'operational' },
        open_incidents: incidents.count { |incident| incident[:state] != 'resolved' }
      }
    end
  end
end
