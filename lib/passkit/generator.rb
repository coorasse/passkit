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
      clean_ds_store_files
      I18n.with_locale(@pass.language) do
        generate_json_pass
      end
      generate_json_manifest
      sign_manifest
      compress_pass_file
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
        foregroundColor: @pass.foreground_color,
        backgroundColor: @pass.background_color,
        webServiceURL: @pass.web_service_url,
        barcode: @pass.barcode,
        voided: @pass.voided,
        organizationName: @pass.organization_name,
        description: @pass.description,
        logoText: @pass.logo_text,
        locations: @pass.locations
      }

      pass = pass.merge({
        serialNumber: @pass.serial_number,
        passTypeIdentifier: @pass.pass_type_identifier,
        authenticationToken: @pass.authentication_token
      })

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

    # :nocov:
    def sign_manifest
      p12_certificate = OpenSSL::PKCS12.new(File.read(Rails.root.join(Passkit.configuration.private_p12_certificate)), Passkit.configuration.certificate_key)
      intermediate_certificate = OpenSSL::X509::Certificate.new(File.read(Rails.root.join(Passkit.configuration.apple_intermediate_certificate)))

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
