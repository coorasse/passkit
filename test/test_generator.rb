# frozen_string_literal: true

require "rails_helper"

class TestGenerator < ActiveSupport::TestCase
  def test_generate_and_sign_leaves_only_the_pkpass_behind
    pass = Passkit::Pass.create!(klass: Passkit::ExampleStoreCard)

    path = Passkit::Generator.new(pass).generate_and_sign

    assert File.exist?(path)
    refute File.directory?(Passkit::Generator::TMP_FOLDER.join(pass.file_name.to_s))
  ensure
    FileUtils.rm_f(path) if path
  end

  def test_generate_and_sign_removes_the_working_directory_when_signing_fails
    pass = Passkit::Pass.create!(klass: Passkit::ExampleStoreCard)
    generator = Passkit::Generator.new(pass)

    generator.stub(:sign_manifest, -> { raise OpenSSL::PKCS7::PKCS7Error, "bad certificate" }) do
      assert_raises(OpenSSL::PKCS7::PKCS7Error) { generator.generate_and_sign }
    end

    refute File.directory?(Passkit::Generator::TMP_FOLDER.join(pass.file_name.to_s))
  end
end
