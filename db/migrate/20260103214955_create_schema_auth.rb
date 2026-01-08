class CreateSchemaAuth < ActiveRecord::Migration[8.1]
  def change
    execute "CREATE SCHEMA IF NOT EXISTS auth"
  end

  def down
    execute "DROP SCHEMA IF EXISTS auth"
  end
end
