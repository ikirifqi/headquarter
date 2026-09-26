require 'test_helper'

module Dummy
  class BillingTest < ActiveSupport::TestCase
    setup { @billing = Billing.new(Dummy.data) }

    test 'lists bills due within 90 days in date order' do
      dates = @billing.bills.pluck(:date)

      assert_equal dates.sort, dates
      assert(dates.all? { |date| date.between?(Date.new(2026, 9, 15), Date.new(2026, 12, 14)) })
    end

    test 'splits the total into recurring and one-time payments' do
      summary = @billing.summary

      assert_equal 32_757, summary[:total]
      assert_equal summary[:total], summary[:recurring] + summary[:one_time]
      assert_equal 10_910, summary[:one_time]
    end

    test 'sums payments due in the next 30 days and lists the first three' do
      due_soon = @billing.due_soon

      assert_equal 10_427, due_soon[:total]
      assert_equal %w[OpenAI Vercel Anthropic], due_soon[:next].pluck(:platform)
    end
  end
end
