# Subscriptions and one-time payments due over the next 90 days
class BillingController < InertiaController
  def show
    billing = Dummy::Billing.new(dummy)

    render inertia: { summary: billing.summary, bills: billing.bills }
  end
end
