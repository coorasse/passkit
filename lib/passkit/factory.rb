module Passkit
  class Factory
    class << self
      # generator is an optional ActiveRecord object, the application data for the pass
      def create_pass(pass_class, generator = nil)
        pass = Passkit::Pass.create!(klass: pass_class, generator: generator)
        Passkit::Generator.new(pass).generate_and_sign
      end
    end
  end
end
