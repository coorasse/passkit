module Passkit
  class PayloadGenerator
    VALIDITY = 30.days

    def self.encrypted(pass_class, generator = nil)
      UrlEncrypt.encrypt(hash(pass_class, generator))
    end

    def self.hash(pass_class, generator = nil)
      valid_until = VALIDITY.from_now

      {valid_until: valid_until,
       generator_class: generator&.class&.name,
       generator_id: generator&.id,
       pass_class: pass_class.name}
    end
  end
end
