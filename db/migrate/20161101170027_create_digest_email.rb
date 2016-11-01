class CreateDigestEmail < ActiveRecord::Migration
  def change
    create_table :digest_emails do |t|
      t.string    :email
      t.boolean   :active
    end
  end
end
