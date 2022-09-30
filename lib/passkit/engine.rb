# frozen_string_literal: true

module Passkit
  class Engine < ::Rails::Engine
    isolate_namespace Passkit
  end
end
