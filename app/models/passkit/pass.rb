module Passkit
  class Pass < ActiveRecord::Base
    validates_uniqueness_of :serial_number
    validates_presence_of :klass

    belongs_to :generator, polymorphic: true, optional: true
    has_many :registrations, foreign_key: :passkit_pass_id
    has_many :devices, through: :registrations

    delegate :apple_team_identifier,
      :app_launch_url,
      :associated_store_identifiers,
      :auxiliary_fields,
      :back_fields,
      :background_color,
      :barcode,
      :barcodes,
      :beacons,
      :boarding_pass,
      :description,
      :expiration_date,
      :file_name,
      :foreground_color,
      :format_version,
      :grouping_identifier,
      :header_fields,
      :label_color,
      :language,
      :locations,
      :logo_text,
      :max_distance,
      :nfc,
      :organization_name,
      :pass_path,
      :pass_type,
      :pass_type_identifier,
      :primary_fields,
      :relevant_date,
      :secondary_fields,
      :semantics,
      :sharing_prohibited,
      :suppress_strip_shine,
      :user_info,
      :voided,
      :web_service_url,
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
