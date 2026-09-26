module Dummy
  # Upcoming payments over the next 90 days
  class Billing
    WINDOW_DAYS = 90
    SOON_DAYS = 30

    def initialize(data)
      @data = data
      @today = data.dig(:organization, :today)
    end

    def bills
      @bills ||= @data[:bills]
                 .each_with_index.map { |bill, index| bill.merge(id: index + 1) }
                 .select { |bill| bill[:date].between?(@today, @today + WINDOW_DAYS) }
                 .sort_by { |bill| bill[:date] }
    end

    def summary
      one_time, recurring = bills.partition { |bill| bill[:kind] == 'one_time' }
      { total: total(bills), recurring: total(recurring), one_time: total(one_time), count: bills.size }
    end

    def due_soon
      soon = bills.select { |bill| bill[:date] <= @today + SOON_DAYS }
      { total: total(soon), next: soon.first(3).map { |bill| bill.slice(:id, :date, :platform, :amount) } }
    end

    private

    def total(bills)
      bills.sum { |bill| bill[:amount] }
    end
  end
end
