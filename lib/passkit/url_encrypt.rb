module Passkit
  class UrlEncrypt
    class << self
      def encrypt(payload)
        string = payload.to_json
        cipher = cypher.encrypt
        cipher.key = encryption_key
        s = cipher.update(string) + cipher.final

        s.unpack1("H*").upcase
      end

      def decrypt(string)
        cipher = cypher.decrypt
        cipher.key = encryption_key
        s = [string].pack("H*").unpack("C*").pack("c*")

        JSON.parse(cipher.update(s) + cipher.final, symbolize_names: true)
      end

      private

      def encryption_key
        Rails.application.secret_key_base[0..15]
      end

      def cypher
        OpenSSL::Cipher.new("AES-128-CBC")
      end
    end
  end
end
