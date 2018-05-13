class DropDigestEmails < ActiveRecord::Migration
  def change
    drop_table :digest_emails
  end
end
