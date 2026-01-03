class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table 'auth.users' do |t|
      t.string :name
      t.string :email
      t.date :birthdate
      t.string :password

      t.timestamps
    end
  end
end
