class RegisterSqlServerDataTypes < ActiveRecord::Migration
  NAME = 'SQL Server'

  def up
    data_types = [
      { name: 'bigint'          , sizable: false, scalable: false },
      { name: 'int'             , sizable: false, scalable: false },
      { name: 'smallint'        , sizable: false, scalable: false },
      { name: 'tinyint'         , sizable: false, scalable: false },
      { name: 'numeric'         , sizable: true , scalable: true  },
      { name: 'decimal'         , sizable: true , scalable: true  },
      { name: 'smallmoney'      , sizable: false, scalable: false },
      { name: 'money'           , sizable: false, scalable: false },
      { name: 'float'           , sizable: false, scalable: false },
      { name: 'real'            , sizable: false, scalable: false },
      { name: 'bit'             , sizable: false, scalable: false },
      { name: 'date'            , sizable: false, scalable: false },
      { name: 'time'            , sizable: true , scalable: false },
      { name: 'datetime'        , sizable: false, scalable: false },
      { name: 'datetime2'       , sizable: true , scalable: false },
      { name: 'smalldatetime'   , sizable: false, scalable: false },
      { name: 'datetimeoffset'  , sizable: true , scalable: false },
      { name: 'char'            , sizable: true , scalable: false },
      { name: 'varchar'         , sizable: true , scalable: false },
      { name: 'text'            , sizable: false, scalable: false },
      { name: 'binary'          , sizable: true , scalable: false },
      { name: 'varbinary'       , sizable: true , scalable: false },
      { name: 'image'           , sizable: false, scalable: false },
      { name: 'timestamp'       , sizable: false, scalable: false },
      { name: 'uniqueidentifier', sizable: false, scalable: false }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::SqlServer.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::SqlServer.where(name: NAME).first.try(:destroy)
  end
end

