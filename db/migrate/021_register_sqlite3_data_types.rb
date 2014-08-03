class RegisterSqlite3DataTypes < ActiveRecord::Migration
  NAME = 'SQLite3'

  def up
    data_types = [
      { name: 'TEXT'    , sizable: false, scalable: false, use_by_default: true },
      { name: 'NUMERIC' , sizable: false, scalable: false, use_by_default: true },
      { name: 'INTEGER' , sizable: false, scalable: false, use_by_default: true },
      { name: 'REAL'    , sizable: false, scalable: false, use_by_default: true },
      { name: 'NONE'    , sizable: false, scalable: false, use_by_default: true }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::Other.create!(name: NAME, comment: "Builtin DBMS as Other type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::Other.where(name: NAME).first.try(:destroy)
  end
end

