module Passkit
  class Device < ActiveRecord::Base
    validates_uniqueness_of :identifier

    has_many :registrations, foreign_key: :passkit_device_id
    has_many :passes, through: :registrations
  end
end
