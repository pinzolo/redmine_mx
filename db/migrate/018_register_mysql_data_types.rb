class RegisterMysqlDataTypes < ActiveRecord::Migration
  NAME = 'MySQL'

  def up
    data_types = [
      { name: 'TINYINT'         , sizable: true , scalable: false, use_by_default: true  },
      { name: 'SMALLINT'        , sizable: true , scalable: false, use_by_default: false },
      { name: 'MEDIUMINT'       , sizable: true , scalable: false, use_by_default: false },
      { name: 'INT'             , sizable: true , scalable: false, use_by_default: true  },
      { name: 'BIGINT'          , sizable: true , scalable: false, use_by_default: true  },
      { name: 'FLOAT'           , sizable: true , scalable: true , use_by_default: false },
      { name: 'DOUBLE'          , sizable: true , scalable: true , use_by_default: true  },
      { name: 'REAL'            , sizable: true , scalable: true , use_by_default: false },
      { name: 'DOUBLE PRECISION', sizable: true , scalable: true , use_by_default: false },
      { name: 'DECIMAL'         , sizable: true , scalable: true , use_by_default: true  },
      { name: 'NUMERIC'         , sizable: true , scalable: true , use_by_default: false },
      { name: 'FIXED'           , sizable: true , scalable: true , use_by_default: false },
      { name: 'BOOLEAN'         , sizable: false, scalable: false, use_by_default: true  },
      { name: 'BIT'             , sizable: true , scalable: false, use_by_default: false },
      { name: 'DATE'            , sizable: false, scalable: false, use_by_default: true  },
      { name: 'DATETIME'        , sizable: false, scalable: false, use_by_default: true  },
      { name: 'TIME'            , sizable: false, scalable: false, use_by_default: true  },
      { name: 'TIMESTAMP'       , sizable: true , scalable: false, use_by_default: true  },
      { name: 'YEAR'            , sizable: false, scalable: false, use_by_default: false },
      { name: 'CHAR'            , sizable: true , scalable: false, use_by_default: true  },
      { name: 'VARCHAR'         , sizable: true , scalable: false, use_by_default: true  },
      { name: 'TEXT'            , sizable: true , scalable: false, use_by_default: true  },
      { name: 'MEDIUMTEXT'      , sizable: false, scalable: false, use_by_default: false },
      { name: 'LONGTEXT'        , sizable: false, scalable: false, use_by_default: true  },
      { name: 'BLOB'            , sizable: true , scalable: false, use_by_default: true  },
      { name: 'MEDIUMBLOB'      , sizable: false, scalable: false, use_by_default: false },
      { name: 'LONGBLOB'        , sizable: false, scalable: false, use_by_default: true  }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::Mysql.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::Mysql.where(name: NAME).first.destroy
  end
end

