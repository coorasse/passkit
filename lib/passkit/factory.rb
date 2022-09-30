module Passkit
  class Factory
    class << self
      def create_pass(pass_class, generator = nil)
        pass = Pass.create!(klass: pass_class, generator: generator)
        Passkit::Generator.new(pass).generate_and_sign
      end
    end
  end
end
