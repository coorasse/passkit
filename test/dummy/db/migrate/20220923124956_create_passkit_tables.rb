class CreatePasskitTables < ActiveRecord::Migration[7.0]
  def change
    create_table :passkit_passes do |t|
      t.string :generator_type
      t.string :klass
      t.bigint :generator_id
      t.string :serial_number
      t.string :authentication_token
      t.json :data
      t.integer :version
      t.timestamps null: false
      t.index [:generator_type, :generator_id], name: "index_passkit_passes_on_generator"
    end

    create_table :passkit_devices do |t|
      t.string :identifier
      t.string :push_token
      t.timestamps null: false
    end

    create_table :passkit_registrations do |t|
      t.belongs_to :passkit_pass, index: true
      t.belongs_to :passkit_device, index: true
      t.timestamps null: false
    end

    create_table :passkit_logs do |t|
      t.text :content
      t.timestamps null: false
    end
  end
end
