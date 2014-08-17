class RegisterMysqlDataTypes < ActiveRecord::Migration
  NAME = 'MySQL'

  def up
    data_types = [
      { name: 'TINYINT'         , sizable: true , scalable: false },
      { name: 'SMALLINT'        , sizable: true , scalable: false },
      { name: 'MEDIUMINT'       , sizable: true , scalable: false },
      { name: 'INT'             , sizable: true , scalable: false },
      { name: 'BIGINT'          , sizable: true , scalable: false },
      { name: 'FLOAT'           , sizable: true , scalable: true  },
      { name: 'DOUBLE'          , sizable: true , scalable: true  },
      { name: 'REAL'            , sizable: true , scalable: true  },
      { name: 'DOUBLE PRECISION', sizable: true , scalable: true  },
      { name: 'DECIMAL'         , sizable: true , scalable: true  },
      { name: 'NUMERIC'         , sizable: true , scalable: true  },
      { name: 'FIXED'           , sizable: true , scalable: true  },
      { name: 'BOOLEAN'         , sizable: false, scalable: false },
      { name: 'BIT'             , sizable: true , scalable: false },
      { name: 'DATE'            , sizable: false, scalable: false },
      { name: 'DATETIME'        , sizable: false, scalable: false },
      { name: 'TIME'            , sizable: false, scalable: false },
      { name: 'TIMESTAMP'       , sizable: true , scalable: false },
      { name: 'YEAR'            , sizable: false, scalable: false },
      { name: 'CHAR'            , sizable: true , scalable: false },
      { name: 'VARCHAR'         , sizable: true , scalable: false },
      { name: 'TEXT'            , sizable: true , scalable: false },
      { name: 'MEDIUMTEXT'      , sizable: false, scalable: false },
      { name: 'LONGTEXT'        , sizable: false, scalable: false },
      { name: 'BLOB'            , sizable: true , scalable: false },
      { name: 'MEDIUMBLOB'      , sizable: false, scalable: false },
      { name: 'LONGBLOB'        , sizable: false, scalable: false }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::Mysql.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::Mysql.where(name: NAME).first.try(:destroy)
  end
end

