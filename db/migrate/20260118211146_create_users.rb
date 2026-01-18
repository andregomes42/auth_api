class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid, default: -> { 'gen_random_uuid()' } do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.date :birthdate, null: false
      t.string :password, null: false

      t.timestamps
    end
  end
end
