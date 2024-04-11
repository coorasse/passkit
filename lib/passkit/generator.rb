require "zip"

module Passkit
  class Generator
    TMP_FOLDER = Rails.root.join("tmp/passkit").freeze

    def initialize(pass)
      @pass = pass
      @generator = pass.generator
    end

    def generate_and_sign
      check_necessary_files
      create_temporary_directory
      copy_pass_to_tmp_location
      @pass.instance.add_other_files(@temporary_path)
      clean_ds_store_files
      I18n.with_locale(@pass.language) do
        generate_json_pass
      end
      generate_json_manifest
      sign_manifest
      compress_pass_file
    end

    def self.compress_passes_files(files)
      zip_path = TMP_FOLDER.join("#{SecureRandom.uuid}.pkpasses")
      zipped_file = File.open(zip_path, "w")

      Zip::OutputStream.open(zipped_file.path) do |z|
        files.each do |file|
          z.put_next_entry(File.basename(file))
          z.print File.read(file)
        end
      end
      zip_path
    end

  private

    def check_necessary_files
      raise "icon.png is not present in #{@pass.pass_path}" unless File.exist?(File.join(@pass.pass_path, "icon.png"))
    end

    def create_temporary_directory
      FileUtils.mkdir_p(TMP_FOLDER) unless File.directory?(TMP_FOLDER)
      @temporary_path = TMP_FOLDER.join(@pass.file_name.to_s)

      FileUtils.rm_rf(@temporary_path) if File.directory?(@temporary_path)
    end

    def copy_pass_to_tmp_location
      FileUtils.cp_r(@pass.pass_path, @temporary_path)
    end

    def clean_ds_store_files
      Dir.glob(@temporary_path.join("**/.DS_Store")).each { |file| File.delete(file) }
    end

    def generate_json_pass
      pass = {
        formatVersion: @pass.format_version,
        teamIdentifier: @pass.apple_team_identifier,
        authenticationToken: @pass.authentication_token,
        backgroundColor: @pass.background_color,
        description: @pass.description,
        foregroundColor: @pass.foreground_color,
        labelColor: @pass.label_color,
        locations: @pass.locations,
        logoText: @pass.logo_text,
        organizationName: @pass.organization_name,
        passTypeIdentifier: @pass.pass_type_identifier,
        serialNumber: @pass.serial_number,
        sharingProhibited: @pass.sharing_prohibited,
        suppressStripShine: @pass.suppress_strip_shine,
        voided: @pass.voided,
        webServiceURL: @pass.web_service_url
      }

      pass[:maxDistance] = @pass.max_distance if @pass.max_distance

      # If the newer barcodes attribute has been used, then
      # include the list of barcodes, otherwise fall back to
      # the original barcode attribute
      barcodes = @pass.barcodes || []
      if barcodes.empty?
        pass[:barcode] = @pass.barcode
      else
        pass[:barcodes] = @pass.barcodes
      end

      pass[:appLaunchURL] = @pass.app_launch_url if @pass.app_launch_url
      pass[:associatedStoreIdentifiers] = @pass.associated_store_identifiers unless @pass.associated_store_identifiers.empty?
      pass[:beacons] = @pass.beacons unless @pass.beacons.empty?
      pass[:boardingPass] = @pass.boarding_pass if @pass.boarding_pass
      pass[:coupon] = @pass.coupon if @pass.coupon
      pass[:eventTicket] = @pass.event_ticket if @pass.event_ticket
      pass[:expirationDate] = @pass.expiration_date if @pass.expiration_date
      pass[:generic] = @pass.generic if @pass.generic
      pass[:groupingIdentifier] = @pass.grouping_identifier if @pass.grouping_identifier
      pass[:nfc] = @pass.nfc if @pass.nfc
      pass[:relevantDate] = @pass.relevant_date if @pass.relevant_date
      pass[:semantics] = @pass.semantics if @pass.semantics
      pass[:store_card] = @pass.store_card if @pass.store_card
      pass[:userInfo] = @pass.user_info if @pass.user_info

      pass[@pass.pass_type] = {
        headerFields: @pass.header_fields,
        primaryFields: @pass.primary_fields,
        secondaryFields: @pass.secondary_fields,
        auxiliaryFields: @pass.auxiliary_fields,
        backFields: @pass.back_fields
      }

      File.write(@temporary_path.join("pass.json"), pass.to_json)
    end

    # rubocop:enable Metrics/AbcSize

    def generate_json_manifest
      manifest = {}
      Dir.glob(@temporary_path.join("**")).each do |file|
        manifest[File.basename(file)] = Digest::SHA1.hexdigest(File.read(file))
      end

      @manifest_url = @temporary_path.join("manifest.json")
      File.write(@manifest_url, manifest.to_json)
    end

    CERTIFICATE = Rails.root.join(ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"])
    INTERMEDIATE_CERTIFICATE = Rails.root.join(ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"])
    CERTIFICATE_PASSWORD = ENV["PASSKIT_CERTIFICATE_KEY"]

    # :nocov:
    def sign_manifest
      p12_certificate = OpenSSL::PKCS12.new(File.read(CERTIFICATE), CERTIFICATE_PASSWORD)
      intermediate_certificate = OpenSSL::X509::Certificate.new(File.read(INTERMEDIATE_CERTIFICATE))

      flag = OpenSSL::PKCS7::DETACHED | OpenSSL::PKCS7::BINARY
      signed = OpenSSL::PKCS7.sign(p12_certificate.certificate,
        p12_certificate.key, File.read(@manifest_url),
        [intermediate_certificate], flag)

      @signature_url = @temporary_path.join("signature")
      File.open(@signature_url, "w") { |f| f.syswrite signed.to_der }
    end

    # :nocov:

    def compress_pass_file
      zip_path = TMP_FOLDER.join("#{@pass.file_name}.pkpass")
      zipped_file = File.open(zip_path, "w")

      Zip::OutputStream.open(zipped_file.path) do |z|
        Dir.glob(@temporary_path.join("**")).each do |file|
          z.put_next_entry(File.basename(file))
          z.print File.read(file)
        end
      end
      zip_path
    end
  end
end
