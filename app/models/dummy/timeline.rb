module Dummy
  # Positions roadmap milestones as percentages of a fixed window of months
  class Timeline
    def initialize(data)
      @today = data.dig(:organization, :today)
      @starts_on = data.dig(:roadmap, :starts_on)
      @month_count = data.dig(:roadmap, :months)
      @ends_on = @starts_on >> @month_count
    end

    def months
      Array.new(@month_count) { |index| @starts_on >> index }
    end

    def today_offset
      offset(@today)
    end

    def milestones(project)
      project[:milestones].map do |milestone|
        left = offset(milestone[:starts_on])
        milestone.merge(offset: left, span: (offset(milestone[:ends_on] + 1) - left).round(2))
      end
    end

    private

    def offset(date)
      clamped = date.clamp(@starts_on, @ends_on)
      ((clamped - @starts_on) * 100.0 / (@ends_on - @starts_on)).round(2)
    end
  end
end
