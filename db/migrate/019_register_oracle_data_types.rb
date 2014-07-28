class RegisterOracleDataTypes < ActiveRecord::Migration
  NAME = 'Oracle'

  def up
    data_types = [
      { name: 'CHAR'         , sizable: true , scalable: false, use_by_default: true  },
      { name: 'VARCHAR2'     , sizable: true , scalable: false, use_by_default: true  },
      { name: 'NCHAR'        , sizable: true , scalable: false, use_by_default: true  },
      { name: 'NVARCHAR2'    , sizable: true , scalable: false, use_by_default: true  },
      { name: 'CLOB'         , sizable: false, scalable: false, use_by_default: true  },
      { name: 'BLOB'         , sizable: false, scalable: false, use_by_default: true  },
      { name: 'NUMBER'       , sizable: true , scalable: true , use_by_default: true  },
      { name: 'BINARY_FLOAT' , sizable: false, scalable: false, use_by_default: false },
      { name: 'BINARY_DOUBLE', sizable: false, scalable: false, use_by_default: false },
      { name: 'DATE'         , sizable: false, scalable: false, use_by_default: true  },
      { name: 'TIMESTAMP'    , sizable: false, scalable: false, use_by_default: true  },
      { name: 'RAW'          , sizable: true , scalable: false, use_by_default: false }
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

