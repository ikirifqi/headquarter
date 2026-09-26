# Mocked workspace data read from config/dummy.yml. There are no tables behind Headquarter yet:
# every page is built from this file by the classes under Dummy::.
module Dummy
  PATH = Rails.root.join('config/dummy.yml')

  # The whole file with symbolized keys. Read on every call so edits show up without a restart.
  def self.data
    YAML.load_file(PATH, permitted_classes: [Date]).deep_symbolize_keys
  end
end
