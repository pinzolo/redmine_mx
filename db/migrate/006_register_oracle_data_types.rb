class RegisterOracleDataTypes < ActiveRecord::Migration
  NAME = 'Oracle'

  def up
    data_types = [
      { name: 'CHAR'         , sizable: true , scalable: false },
      { name: 'VARCHAR2'     , sizable: true , scalable: false },
      { name: 'NCHAR'        , sizable: true , scalable: false },
      { name: 'NVARCHAR2'    , sizable: true , scalable: false },
      { name: 'CLOB'         , sizable: false, scalable: false },
      { name: 'BLOB'         , sizable: false, scalable: false },
      { name: 'NUMBER'       , sizable: true , scalable: true  },
      { name: 'BINARY_FLOAT' , sizable: false, scalable: false },
      { name: 'BINARY_DOUBLE', sizable: false, scalable: false },
      { name: 'DATE'         , sizable: false, scalable: false },
      { name: 'TIMESTAMP'    , sizable: false, scalable: false },
      { name: 'RAW'          , sizable: true , scalable: false }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::Oracle.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::Oracle.where(name: NAME).first.try(:destroy)
  end
end

