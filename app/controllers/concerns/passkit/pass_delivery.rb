module Passkit
  # Passes are generated into tmp/passkit. Send the archive's contents and
  # delete the file, so the folder does not grow by one archive per download.
  module PassDelivery
    extend ActiveSupport::Concern

    private

    def send_pass_file(path, type:, filename: File.basename(path))
      send_data File.binread(path), type: type, disposition: "attachment", filename: filename
    ensure
      FileUtils.rm_f(path)
    end
  end
end
