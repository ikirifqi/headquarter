class ApplicationService
  include Rails.application.routes.url_helpers

  delegate :t, to: :I18n

  # @return [ApplicationService]
  def self.call(*, &)
    instance = new(*)
    instance.call(&)
    instance
  end

  # return value will be ignored, use attr_reader to expose result
  def call; end
end
