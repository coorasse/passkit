module Passkit
  class Pass < ActiveRecord::Base
    validates_uniqueness_of :serial_number
    validates_presence_of :klass

    belongs_to :generator, polymorphic: true, optional: true
    has_many :registrations, foreign_key: :passkit_pass_id
    has_many :devices, through: :registrations

    delegate :file_name,
      :pass_path,
      :language,
      :format_version,
      :apple_team_identifier,
      :foreground_color,
      :background_color,
      :web_service_url,
      :barcode,
      :voided,
      :organization_name,
      :description,
      :logo_text,
      :locations,
      :pass_type_identifier,
      :pass_type,
      :header_fields,
      :primary_fields,
      :secondary_fields,
      :auxiliary_fields,
      :back_fields,
      to: :instance

    before_validation on: :create do
      self.authentication_token ||= SecureRandom.hex
      loop do
        self.serial_number = SecureRandom.uuid
        break unless self.class.exists?(serial_number: serial_number)
      end
    end

    def instance
      @instance ||= klass.constantize.new(generator)
    end

    def last_update
      instance.last_update || updated_at
    end
  end
end
